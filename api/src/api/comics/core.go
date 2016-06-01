package main

import (
    "log"
    "net/http"
)

func main() {
//After http://thenewstack.io/make-a-restful-json-api-go/

  router := NewRouter()

  log.Fatal(http.ListenAndServe(":8080", router))
}
