package main

import "time"

type Comic struct {
    Id        int        `json:"id"`
    Name      string     `json:"name"`
    Completed bool       `json:"completed"`
    Due       time.Time  `json:"due"`
}

type Comics []Comic

type Title struct {
  Id     int       `json:"id"`
  Name string      `json:"name"`
  Publisher string `json:"publisher"`
  Writer string    `json:"writer"`
  Artist string    `json:"artist"`
}

type Titles []Title

type Issue  struct {
  Id      int       `json:"id"`
  Title string      `json:"title"`
  Signed bool       `json:"signed"`
  Variant string    `json:"variant"`
  Grade float32     `json:"grade"`
}

type Issues []Issue

type Publisher struct {
  Id     int       `json:"id"`
  Name string      `json:"name"`
}

type Publishers []Publisher
