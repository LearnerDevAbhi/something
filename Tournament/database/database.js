var mysql = require('mysql');
var database= {};

//connet to mysql RUMMY DATABASE
database.pool      =    mysql.createPool({
    host     : 'localhost',
    user     : 'root',
    password : '',
    database : 'ludoindia',
    debug    :  false,
    multipleStatements : true           // I like this because it helps prevent nested sql statements, it can be buggy though, so be careful

});

module.exports = database;