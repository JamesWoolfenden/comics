package main

import (
    "fmt"
    "log"
    "net/http"
    "encoding/json"
    "github.com/gorilla/mux"
)

func main() {

    router := mux.NewRouter().StrictSlash(true)
    router.HandleFunc("/", Index)
    router.HandleFunc("/covers", CoversIndex)
    router.HandleFunc("/comics", ComicsIndex)
    router.HandleFunc("/comics/{comicsId}", ComicsShow)

    log.Fatal(http.ListenAndServe(":8080", router))
}

func Index(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Welcome!")
}

func ComicsIndex(w http.ResponseWriter, r *http.Request) {
  comics := Comics{
          Comic{Name: "Velvet"},
          Comic{Name: "The Walking Dead"},
      }

      json.NewEncoder(w).Encode(comics)
}

func ComicsShow(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    comicsId := vars["comicsId"]
    fmt.Fprintln(w, "Comics show:", comicsId)
}

func CoversIndex(w http.ResponseWriter, r *http.Request) {
  publishers := Publishers{
        Publisher{Name: "Image"},
        Publisher{Name: "DC"},
        Publisher{Name: "Marvel"},
      }

      json.NewEncoder(w).Encode(publishers)
}
