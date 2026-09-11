from flask import Flask
app=Flask(__name__)
@app.get('/')
def home(): return 'LAB10 APP\n'
@app.get('/health')
def health(): return {'status':'UP'}
app.run(host='0.0.0.0',port=5000)
