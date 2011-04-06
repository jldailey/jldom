document = require("../dom").createDocument()

document.body.innerHTML = "<div></div>"

console.log document.toString(true, true)
