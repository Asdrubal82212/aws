#!/bin/bash
exec > /var/log/dashboard-init.log 2>&1

yum update -y
yum install -y nginx aws-cli jq

cat > /usr/local/bin/generate-dashboard.sh << 'SCRIPT'
#!/bin/bash
REGION="us-east-1"

BUCKET_ROWS=""
BUCKETS=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text 2>/dev/null)
for bucket in $BUCKETS; do
  BUCKET_REGION=$(aws s3api get-bucket-location --bucket "$bucket" --query 'LocationConstraint' --output text 2>/dev/null || echo "us-east-1")
  [ "$BUCKET_REGION" = "None" ] && BUCKET_REGION="us-east-1"
  BUCKET_ROWS="${BUCKET_ROWS}<tr><td>${bucket}</td><td>${BUCKET_REGION}</td></tr>"
done

DYNAMO_ROWS=""
TABLES=$(aws dynamodb list-tables --region "$REGION" --query 'TableNames[*]' --output text 2>/dev/null)
for table in $TABLES; do
  STATUS=$(aws dynamodb describe-table --region "$REGION" --table-name "$table" --query 'Table.TableStatus' --output text 2>/dev/null || echo "UNKNOWN")
  DYNAMO_ROWS="${DYNAMO_ROWS}<tr><td>${table}</td><td>${STATUS}</td></tr>"
done

cat > /usr/share/nginx/html/index.html << HTML
<!DOCTYPE html>
<html>
<head>
  <title>AWS Dashboard</title>
  <style>
    body { font-family: Arial; background: #1e1e1e; color: #fff; padding: 20px; }
    input, select { padding: 8px; margin: 5px; border-radius: 4px; border: none; width: 200px; }
    button { padding: 8px 14px; margin: 5px; border-radius: 4px; border: none; background: #ff9900; color: #fff; cursor: pointer; }
    button:hover { background: #e68a00; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; margin-bottom: 30px; }
    th, td { padding: 10px; border: 1px solid #444; text-align: left; }
    th { background: #333; }
    tr:hover { background: #2a2a2a; }
    h2 { color: #ff9900; }
    .filters { margin-bottom: 10px; }
  </style>
</head>
<body>
  <h1>AWS Resources Dashboard</h1>
  <h2>Buckets S3</h2>
  <div class="filters">
    <input type="text" onkeyup="filterCol('bucketTable', 0, this.value)" placeholder="Filtrar por nombre...">
    <input type="text" onkeyup="filterCol('bucketTable', 1, this.value)" placeholder="Filtrar por region...">
    <button onclick="clearFilters('bucketTable')">Mostrar todos</button>
  </div>
  <table id="bucketTable">
    <tr><th>Nombre</th><th>Region</th></tr>
    ${BUCKET_ROWS}
  </table>
  <h2>Tablas DynamoDB</h2>
  <div class="filters">
    <input type="text" onkeyup="filterCol('dynamoTable', 0, this.value)" placeholder="Filtrar por nombre...">
    <select onchange="filterCol('dynamoTable', 1, this.value)">
      <option value="">Todos los estados</option>
      <option value="ACTIVE">ACTIVE</option>
      <option value="CREATING">CREATING</option>
      <option value="DELETING">DELETING</option>
      <option value="UPDATING">UPDATING</option>
    </select>
    <button onclick="clearFilters('dynamoTable')">Mostrar todas</button>
  </div>
  <table id="dynamoTable">
    <tr><th>Nombre</th><th>Estado</th></tr>
    ${DYNAMO_ROWS}
  </table>
  <script>
    function filterCol(tableId, col, value) {
      var filter = value.toUpperCase();
      var rows = document.getElementById(tableId).getElementsByTagName('tr');
      for (var i = 1; i < rows.length; i++) {
        var td = rows[i].getElementsByTagName('td')[col];
        if (td) rows[i].style.display = td.innerHTML.toUpperCase().includes(filter) ? '' : 'none';
      }
    }
    function clearFilters(tableId) {
      var rows = document.getElementById(tableId).getElementsByTagName('tr');
      for (var i = 1; i < rows.length; i++) rows[i].style.display = '';
    }
  </script>
</body>
</html>
HTML
SCRIPT

chmod +x /usr/local/bin/generate-dashboard.sh
/usr/local/bin/generate-dashboard.sh

mkdir -p /etc/cron.d
echo "*/5 * * * * root /usr/local/bin/generate-dashboard.sh" > /etc/cron.d/dashboard

systemctl enable nginx
systemctl start nginx
