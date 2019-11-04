package main

import "fmt"
import "time"

func main() {
    honk :=
`_   _  ___  _   _ _   ___ _
| | | |/ _ \| \ | | | / / | |
| |_| | | | |  \| | |/ /| | |
|  _  | | | |     |   < |_|_|
| | | | |_| | |\  | |\ \ _ _
|_| |_|\___/|_| \_|_| \_(_|_)
`
    fmt.Println(honk)
    fmt.Println("Not the container image you were expecting?")
    fmt.Println("Relax, you have only been h0nX0r3d, not hacked.")
    fmt.Println("For more information on why you are seeing this:")
    fmt.Println("https://github.com/bgeesaman/registry-search-order")
    time.Sleep(10 * time.Second)
}
