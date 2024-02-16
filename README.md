# MyMap3
Google登入、商品列表、地圖顯示、各牧場標記、當前位置標記、南北路徑，貸款資訊、當前天氣、圖表顯示、plist路徑顯示

![image](https://user-images.githubusercontent.com/71810019/185786632-7554b016-6831-4e22-9d0f-e3e7264bf6d3.jpeg)
![image](https://user-images.githubusercontent.com/71810019/185786636-aeef6499-08b2-455a-b281-87bd7d0a721e.jpeg)
![image](https://user-images.githubusercontent.com/71810019/185786640-1de8168f-8e3b-4b63-80ea-e18433287998.jpeg)

![420558357_6795827997192307_5281792348679379556_n](https://github.com/sme322-ui/MyMap3/assets/71810019/73aa3678-ce6e-479b-b26e-3cb01dc20223)





======================== NodeJs file ===============================================
* var mysql = require('mysql'); //node Js include mysql library

* mysql.createConnection() //connect database

* mysql Insert data,EX：
  var  addSql = 'INSERT INTO temp(timStamp,temperature) values (?,?)';
                      connection.query(addSql,addSqlParams,function (err, result) {
...
  
});
 
connection.end();

*Set up connection port:
Ex：
var server = app.listen(5501,function(){
   console.log("伺服器在5501 port");
});
