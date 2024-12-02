from flask import Flask, request, jsonify, render_template
import boto3
import tempfile
import os
from botocore.exceptions import NoCredentialsError, ClientError

project_root = os.path.dirname(__file__)
template_path = os.path.join(project_root, './')

app = Flask(__name__, template_folder=template_path)
s3 = boto3.client('s3')

@app.route('/puppies', methods=['GET'])
def list():
    bucket_name = os.environ.get('BUCKET_NAME')
    if not bucket_name:
        return jsonify({'error': 'No bucket name provided'}), 400

    try:
        response = s3.list_objects_v2(Bucket=bucket_name)
        files = [item['Key'] for item in response.get('Contents', [])]
        return jsonify({'files': files}), 200
    except NoCredentialsError:
        return jsonify({'error': 'Credentials not available'}), 403
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/puppies/<string:object_key>', methods=['GET'])
def fetch(object_key):
    bucket_name = os.environ.get('BUCKET_NAME')
    
    if not bucket_name or not object_key:
        return jsonify({'error': 'Both the object_key path param and the bucket_name query param must be provided'}), 400
    
    try:
        s3.head_bucket(Bucket=bucket_name)
    except ClientError as e:
        return jsonify({'error': f'error: {e}'}), 400

    try:
        presignedURL = s3.generate_presigned_url('get_object', Params={'Bucket': bucket_name, 'Key': object_key}, ExpiresIn=3600)
        return render_template('index.html', imagePath=presignedURL)

    except ClientError as e:
        return jsonify({'error': str(e)}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
