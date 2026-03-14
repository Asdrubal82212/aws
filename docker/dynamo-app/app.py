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
