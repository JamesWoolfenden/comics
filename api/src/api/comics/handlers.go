package main

import (
    "encoding/json"
    "fmt"
    "net/http"
    "io/ioutil"
    "github.com/gorilla/mux"
)

func Index(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Welcome!\n")
}

func ComicIndex(w http.ResponseWriter, r *http.Request) {

  var comics []Comic
  x:=0

  files, _ := ioutil.ReadDir("..\\..\\covers")
    for _, f := range files {
        comics=append(comics, Comic{Name:f.Name(), Id:x})
                  x++
          }

      w.Header().Set("Content-Type", "application/json; charset=UTF-8")
      w.WriteHeader(http.StatusOK)

      if err := json.NewEncoder(w).Encode(comics); err != nil {
        panic(err)
    }
}

func ComicShow(w http.ResponseWriter, r *http.Request) {
  vars := mux.Vars(r)
  comicId := vars["comicId"]
  fmt.Fprintln(w, "Comics show:", comicId)
}

/*
Test with this curl command:

curl -H "Content-Type: application/json" -d '{"name":"New Todo"}' http://localhost:8080/todos

*/
func ComicCreate(w http.ResponseWriter, r *http.Request) {
    /*var comic Comic
    body, err := ioutil.ReadAll(io.LimitReader(r.Body, 1048576))
    if err != nil {
        panic(err)
    }
    if err := r.Body.Close(); err != nil {
        panic(err)
    }
    if err := json.Unmarshal(body, &comic); err != nil {
        w.Header().Set("Content-Type", "application/json; charset=UTF-8")
        w.WriteHeader(422) // unprocessable entity
        if err := json.NewEncoder(w).Encode(err); err != nil {
            panic(err)
        }
    }

    t := RepoCreateComic(comic)
    w.Header().Set("Content-Type", "application/json; charset=UTF-8")
    w.WriteHeader(http.StatusCreated)
    if err := json.NewEncoder(w).Encode(t); err != nil {
        panic(err)
    }*/
}

func CoverIndex(w http.ResponseWriter, r *http.Request) {

      var publishers []Publisher
      x:=0

      files, _ := ioutil.ReadDir("..\\publishers")
          for _, f := range files {
                  publishers=append(publishers, Publisher{Name:f.Name(), Id:x})
                  x++
          }

      w.Header().Set("Content-Type", "application/json; charset=UTF-8")
      w.WriteHeader(http.StatusOK)

      if err := json.NewEncoder(w).Encode(publishers); err != nil {
        panic(err)
    }
}

func CoverShow(w http.ResponseWriter, r *http.Request) {

    vars := mux.Vars(r)
    coverId := vars["coverId"]
    fmt.Fprintln(w, "Covers show:", coverId)
}
