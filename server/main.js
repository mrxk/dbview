import sql from './db.js'
import http from 'node:http'
import express from 'express'

process.on('SIGINT', function() {
    process.exit();
});

const app = express();
app.use(express.static('../html'));
app.use(express.json());
app.post('/postgres', (req, res) => {
    console.log("====================");
    const query = req.body.query;
    console.log(query);
    sql.unsafe(query)
        .then((result) => {
            const data = {
                count : 0
            };
            if (result.length > 0) {
                data.count = result.count;
                data.columns = result.columns.map( (c) => c.name );
                data.rows = result.map( (r) => Object.values(r) );
            }
            res.statusCode = 200;
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify(data));
        })
        .catch((reason) => {
            const error = {
                message : reason.message,
                severity : reason.severity,
                code : reason.code
            };
            console.log(error);
            res.statusCode = 200;
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify(error));
        })
})

app.listen(8080, '0.0.0.0', () => {
    console.log('http://localhost:8080');
})