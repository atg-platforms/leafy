const app = require('./index')
const port = 3000

app.listen(port, () => 
  console.log(`App is listening on port ${port}.`)
)