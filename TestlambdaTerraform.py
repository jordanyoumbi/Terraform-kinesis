import base64
import gzip
import io
import json
import zlib

def cloudwatch_handler(event, context):
  output = []
  
  for record in event['records']:
    compressed_payload = base64.b64decode(record['data'])
    uncompressed_payload = gzip.decompress(compressed_payload)
    print('uncompressed_payload',uncompressed_payload)
    payload = json.loads(uncompressed_payload)
    output_record = {
        'recordId': record['recordId'],
        'result': 'Ok',
        'data': base64.b64encode(json.dumps(payload).encode('utf-8')).decode('utf-8')
    }
    output.append(output_record)
  print('Successfully processed {} records.'.format(len(event['records'])))
  return {'records': output}
