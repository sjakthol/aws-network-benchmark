import datetime
import gzip
import json
import logging
import os
import subprocess

import botocore.session

def drop_streams(i):
    del i['streams']
    return i

def handler(event, context):
    logging.getLogger().setLevel(logging.INFO)
    logging.info('Starting benchmark')
    try:
        res = subprocess.run(['./lib/iperf3', '--client', os.environ.get('IPERF_SERVER_IP'), '--time', '60', '--interval', '1', '--json'], capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        logging.exception('iperf3 failed')
        logging.info('Output: %s', e.output)
        raise

    logging.info('Benchmark completed. Processing results')
    data = json.loads(res.stdout)

    ts = datetime.datetime.utcnow().isoformat()
    output = {
        'aws_region': os.environ.get('AWS_REGION'),
        'client': { 'type': 'lambda', 'memory': os.environ.get('AWS_LAMBDA_FUNCTION_MEMORY_SIZE') },
        'end': data['end'],
        'intervals': list(map(drop_streams, data['intervals'])),
        'server': { 'type': 'ec2' },
        'start': data['start'],
        'timestamp': ts
    }

    output_bytes = gzip.compress(json.dumps(output).encode('utf-8'))

    bucket = os.environ.get('REPORT_BUCKET')
    key = 'reports/date=%s/run=lambda_60s_out/lambda-%s-%s.json.gz' % (
        datetime.datetime.now().date().isoformat(),
        os.environ.get('AWS_LAMBDA_FUNCTION_MEMORY_SIZE'),
        ts
    )

    logging.info('Writing report to s3://%s/%s' % (bucket, key))
    session = botocore.session.get_session()
    s3 = session.create_client('s3')
    s3.put_object(Bucket=bucket, Key=key, Body=output_bytes)

    logging.info('Done. Goodbye!')