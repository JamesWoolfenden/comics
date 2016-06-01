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
  PublisherID int  `json:"publisherid"`
  Writer string    `json:"writer"`
  Artist string    `json:"artist"`
}

type Titles []Title

type Issue  struct {
  Id      int       `json:"id"`
  TitleID   int     `json:"titleid"`
  Variant string    `json:"variant"`
  ImageSrc string   `json:"imagesrc"`
}

type Issues []Issue

type Sale struct {
  Id     int             `json:"id"`
  Signed bool            `json:"signed"`
  IssueID  int           `json:"issueid"`
  Grade  float32         `json:"grade"`
  Price  float32         `json:"price"`
  SaleDate time.Time     `json:"saledate"`
}

type Sales []Sale


type Publisher struct {
  Id     int       `json:"id"`
  Name string      `json:"name"`
}

type Publishers []Publisher
