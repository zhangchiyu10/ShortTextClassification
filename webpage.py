# -*- coding: utf-8 -*-
import web

urls = ('/', 'Upload')

class Upload:
    def GET(self):
        web.header("Content-Type","text/html; charset=utf-8")
        return """<html><head><title>RHadoop短文本分类平台</title></head><body>
<center>
<h1>RHadoop短文本分类平台</h1>
<form method="POST" enctype="multipart/form-data" action="">
<label>
	    选择要分析的csv文件
		</label>
<input type="file" name="myfile" />
</br><label>
	    选择词库的csv文件
		</label>
<input type="file" name="myfile2" />
<br/>
<input type="submit" name="sub" value="上传词库及文件">
</form>
</center>
</body></html>"""

    def POST(self):
        x = web.input(myfile={},myfile2={})
        filedir = 'data' # change this to the directory you want to store the file in.
        filedir2 = 'data'
        if 'myfile' in x: # to check if the file-object is created
            filepath=x.myfile.filename.replace('\\','/') # replaces the windows-style slashes with linux ones.
            filename=filepath.split('/')[-1] # splits the and chooses the last part (the filename with extension)
            #filename = filename.encode("gb2312")
            fout = open(filedir +'/'+ filename,'w') # creates the file where the uploaded file should be stored
            fout.write(x.myfile.file.read()) # writes the uploaded file to the newly created file.
            fout.close() # closes the file, upload complete.
        if 'myfile2' in x: # to check if the file-object is created
            filepath2=x.myfile2.filename.replace('\\','/') # replaces the windows-style slashes with linux ones.
            filename2=filepath2.split('/')[-1] # splits the and chooses the last part (the filename with extension)
            #filename2 = filename2.encode("gb2312")
            fout2 = open(filedir2 +'/'+ filename2,'w') # creates the file where the uploaded file should be stored
            fout2.write(x.myfile2.file.read()) # writes the uploaded file to the newly created file.
            fout2.close() # closes the file, upload complete.
       # raise web.seeother('/upload')


if __name__ == "__main__":
   app = web.application(urls, globals()) 
   app.run()
