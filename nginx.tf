resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = ["sg-07485c290aa7dbe75"]
  iam_instance_profile   = "agvrol"

  user_data = <<-EOF
    #!/bin/bash
    yum update
    yum install -y nginx aws-cli jq
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head>
      <title>AWS Dashboard</title>
      <style>
        body { font-family: Arial; background: #1e1e1e; color: #fff; padding: 20px; }
        input, select { padding: 8px; margin: 5px; border-radius: 4px; border: none; width: 200px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; margin-bottom: 30px; }
        th, td { padding: 10px; border: 1px solid #444; text-align: left; }
        th { background: #333; }
        tr:hover { background: #2a2a2a; }
        h2 { color: #ff9900; }
        .filters { margin-bottom: 10px; }
      </style>
    </head>
    <body>
      <h1>🌐 AWS Resources Dashboard</h1>

      <h2>🪣 Buckets S3</h2>
      <div class="filters">
        <input type="text" id="filterBucketName" onkeyup="filterCol('bucketTable', 0, this.value)" placeholder="Filtrar por nombre...">
        <input type="text" id="filterBucketRegion" onkeyup="filterCol('bucketTable', 1, this.value)" placeholder="Filtrar por región...">
        <button onclick="clearFilters('bucketTable')">Mostrar todos</button>
      </div>
      <table id="bucketTable">
        <tr><th>Nombre</th><th>Región</th></tr>
        %BUCKETS%
      </table>

      <h2>🗄️ Tablas DynamoDB</h2>
      <div class="filters">
        <input type="text" id="filterDynamoName" onkeyup="filterCol('dynamoTable', 0, this.value)" placeholder="Filtrar por nombre...">
        <select onchange="filterCol('dynamoTable', 1, this.value)">
          <option value="">Todos los estados</option>
          <option value="ACTIVE">Activa</option>
          <option value="INACTIVE">Inactiva</option>
        </select>
        <button onclick="clearFilters('dynamoTable')">Mostrar todas</button>
      </div>
      <table id="dynamoTable">
        <tr><th>Nombre</th><th>Estado</th></tr>
        %DYNAMO%
      </table>

      <script>
        function filterCol(tableId, col, value) {
          var filter = value.toUpperCase();
          var rows = document.getElementById(tableId).getElementsByTagName('tr');
          for (var i = 1; i < rows.length; i++) {
            var td = rows[i].getElementsByTagName('td')[col];
            if (td) {
              rows[i].style.display = td.innerHTML.toUpperCase().includes(filter) ? '' : 'none';
            }
          }
        }
        function clearFilters(tableId) {
          var rows = document.getElementById(tableId).getElementsByTagName('tr');
          for (var i = 1; i < rows.length; i++) {
            rows[i].style.display = '';
          }
        }
      </script>
    </body>
    </html>
    HTML
    systemctl restart nginx
  EOF

  tags = {
    Name = var.project_name
  }
}

output "web_url" {
  value = "http://${aws_instance.web.public_ip}"
}