package main

import (
    "net/http"

)

type Route struct {
    Name        string
    Method      string
    Pattern     string
    HandlerFunc http.HandlerFunc
}

type Routes []Route


var routes = Routes{
    Route{
        "Index",
        "GET",
        "/",
        Index,
    },
    Route{
        "ComicIndex",
        "GET",
        "/comics",
        ComicIndex,
    },
    Route{
	      "ComicCreate",
	      "POST",
	      "/comics",
        ComicCreate,
	},
    Route{
        "ComicsShow",
        "GET",
        "/comics/{comicId}",
        ComicShow,
    },
    Route{
        "CoverIndex",
        "GET",
        "/covers",
        CoverIndex,
    },
    Route{
        "CoverShow",
        "GET",
        "/covers/{coverId}",
        CoverShow,
    },
}
