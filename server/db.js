import postgres from 'postgres'

var max = 8080
if (process.env.MAX_CONNECTIONS !== undefined) {
    max = parseInt(process.env.MAX_CONNECTIONS, 10)
}
const sql = postgres({ssl: 'prefer', max: max})
export default sql
