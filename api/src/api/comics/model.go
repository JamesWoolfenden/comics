package main

import "time"

type Comic struct {
    Name      string     `json:"name"`
    Completed bool       `json:"completed"`
    Due       time.Time  `json:"due"`
}

type Comics []Comic

type Title struct {
  Name string      `json:"name"`
  Publisher string `json:"publisher"`
  Writer string    `json:"writer"`
  Artist string    `json:"artist"`
}

type Titles []Title

type Issue  struct {
  Title string      `json:"title"`
  Signed bool       `json:"signed"` 
  Variant string    `json:"variant"`
  Grade float32     `json:"grade"`
}

type Issues []Issue

type Publisher struct {
  Name string      `json:"name"`
}

type Publishers []Publisher
