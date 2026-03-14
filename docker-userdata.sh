#!/bin/bash
exec > /var/log/docker-init.log 2>&1

yum update -y
yum install -y docker
systemctl enable docker
systemctl start docker

mkdir -p /opt/dynamo-app

cat > /opt/dynamo-app/app.py << 'APPEOF'
from flask import Flask, request, jsonify
import boto3
import uuid

app = Flask(__name__)
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('contenedores')

@app.route('/insertar', methods=['POST'])
def insertar():
    data = request.json
    item = {
        'id': str(uuid.uuid4()),
        'nombre': data.get('nombre')
    }
    table.put_item(Item=item)
    return jsonify({'mensaje': 'Elemento insertado', 'item': item}), 201

@app.route('/consultar', methods=['GET'])
def consultar():
    response = table.scan()
    return jsonify({'items': response['Items']}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
APPEOF

cat > /opt/dynamo-app/requirements.txt << 'REQEOF'
flask==3.0.0
boto3==1.34.0
REQEOF

cat > /opt/dynamo-app/Dockerfile << 'DEOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
DEOF

cd /opt/dynamo-app
docker build -t dynamo-app .
docker run -d --name dynamo-container -p 5000:5000 dynamo-app
