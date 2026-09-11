from flask import Flask
app=Flask(__name__)
@app.get('/')
def home(): return 'LAB6 Flask App\n'
@app.get('/function')
def fn(): return {'status':'processed'}
app.run(host='0.0.0.0',port=5000)
