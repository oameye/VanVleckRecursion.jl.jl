window.BENCHMARK_DATA = {
  "lastUpdate": 1749397555377,
  "repoUrl": "https://github.com/oameye/VanVleckRecursion.jl",
  "entries": {
    "Benchmark Results": [
      {
        "commit": {
          "author": {
            "email": "orjan.ameye@hotmail.com",
            "name": "Orjan Ameye",
            "username": "oameye"
          },
          "committer": {
            "email": "orjan.ameye@hotmail.com",
            "name": "Orjan Ameye",
            "username": "oameye"
          },
          "distinct": true,
          "id": "1b64f4d8237fffc0581dd9572071441d398047ba",
          "message": "export Terms and Term in VanVleckRecursion module",
          "timestamp": "2025-06-02T00:16:31+02:00",
          "tree_id": "3db9860d52a133671d69b81b9665182dcf5cdec1",
          "url": "https://github.com/oameye/VanVleckRecursion.jl/commit/1b64f4d8237fffc0581dd9572071441d398047ba"
        },
        "date": 1748816346182,
        "tool": "julia",
        "benches": [
          {
            "name": "van Vleck expansion/Fifth order",
            "value": 1885001363,
            "unit": "ns",
            "extra": "gctime=12534519\nmemory=140334744\nallocs=1794987\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":50,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "orjan.ameye@hotmail.com",
            "name": "Orjan Ameye",
            "username": "oameye"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "5659f79ecffc007ae8510d32c28a0cff79f4e9bc",
          "message": "Merge pull request #2 from oameye/enable-codecov",
          "timestamp": "2025-06-02T00:47:24+02:00",
          "tree_id": "2d5a4fcb6226e120674927d6e00afb5817639e7e",
          "url": "https://github.com/oameye/VanVleckRecursion.jl/commit/5659f79ecffc007ae8510d32c28a0cff79f4e9bc"
        },
        "date": 1748818181478,
        "tool": "julia",
        "benches": [
          {
            "name": "van Vleck expansion/Fifth order",
            "value": 1897707428,
            "unit": "ns",
            "extra": "gctime=12399719\nmemory=140334744\nallocs=1794987\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":50,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "orjan.ameye@hotmail.com",
            "name": "Orjan Ameye",
            "username": "oameye"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "fd7ee7075c66e70461c4a0e8c28d30a30252dbdc",
          "message": "test: add some doctests (#4)",
          "timestamp": "2025-06-02T11:06:12+02:00",
          "tree_id": "f70242816eb80fe6b524c0a94bdbc3ccbbf3275a",
          "url": "https://github.com/oameye/VanVleckRecursion.jl/commit/fd7ee7075c66e70461c4a0e8c28d30a30252dbdc"
        },
        "date": 1748855311899,
        "tool": "julia",
        "benches": [
          {
            "name": "van Vleck expansion/Fifth order",
            "value": 1889772734,
            "unit": "ns",
            "extra": "gctime=13471488\nmemory=140334744\nallocs=1794987\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":50,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "orjan.ameye@hotmail.com",
            "name": "Orjan Ameye",
            "username": "oameye"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "61d0fcd8569cc584f61f248635b65a2e17b99e20",
          "message": "test: add some latex tests (#5)",
          "timestamp": "2025-06-02T11:17:38+02:00",
          "tree_id": "566f4a532b7fe4822792768708adb60ad772c85d",
          "url": "https://github.com/oameye/VanVleckRecursion.jl/commit/61d0fcd8569cc584f61f248635b65a2e17b99e20"
        },
        "date": 1748855995632,
        "tool": "julia",
        "benches": [
          {
            "name": "van Vleck expansion/Fifth order",
            "value": 1887399746,
            "unit": "ns",
            "extra": "gctime=12596831\nmemory=140334744\nallocs=1794987\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":50,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "orjan.ameye@hotmail.com",
            "name": "Orjan Ameye",
            "username": "oameye"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "bc925cede3274d9aea913300838151571a3455fc",
          "message": "docs: add van Vleck tutorial (#6)\n\n* docs: add van Vleck tutorial\n\n* fix spelling\n\n* fix spelling #2\n\n* test: add missing @test macro for K(1) and K(2) representations\n\n* some small formatting\n\n* format",
          "timestamp": "2025-06-02T16:45:01+01:00",
          "tree_id": "efbf7136aade094ee3487fe4be21bd699b300dff",
          "url": "https://github.com/oameye/VanVleckRecursion.jl/commit/bc925cede3274d9aea913300838151571a3455fc"
        },
        "date": 1748879240530,
        "tool": "julia",
        "benches": [
          {
            "name": "van Vleck expansion/Fifth order",
            "value": 1888835950,
            "unit": "ns",
            "extra": "gctime=13601260\nmemory=140334744\nallocs=1794987\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":50,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "orjan.ameye@hotmail.com",
            "name": "Orjan Ameye",
            "username": "oameye"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "f09a6aafdf4ba2d8bdf7bdf9d74f8883525c8476",
          "message": "test: add ExplicitImports checks (#14)",
          "timestamp": "2025-06-08T17:21:31+02:00",
          "tree_id": "05f5ff25bb52a96df723bf8acfe000f9e5aa9b86",
          "url": "https://github.com/oameye/VanVleckRecursion.jl/commit/f09a6aafdf4ba2d8bdf7bdf9d74f8883525c8476"
        },
        "date": 1749396233274,
        "tool": "julia",
        "benches": [
          {
            "name": "van Vleck expansion/Fifth order",
            "value": 1877133190,
            "unit": "ns",
            "extra": "gctime=12394065\nmemory=140334744\nallocs=1794987\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":50,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "orjan.ameye@hotmail.com",
            "name": "Orjan Ameye",
            "username": "oameye"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "cc4c453c3bdf68849cf808a51f5bf674f74111b2",
          "message": "test: add DispatchDoctor (no type-stability) (#15)",
          "timestamp": "2025-06-08T17:40:39+02:00",
          "tree_id": "24a3b714009e4033a575c38b0d63de4825d5ab1f",
          "url": "https://github.com/oameye/VanVleckRecursion.jl/commit/cc4c453c3bdf68849cf808a51f5bf674f74111b2"
        },
        "date": 1749397381123,
        "tool": "julia",
        "benches": [
          {
            "name": "van Vleck expansion/Fifth order",
            "value": 1886779167,
            "unit": "ns",
            "extra": "gctime=12598204\nmemory=140334744\nallocs=1794987\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":50,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "orjan.ameye@hotmail.com",
            "name": "Orjan Ameye",
            "username": "oameye"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "cea0869e430d5e7afd87fbccb5b1e4169bd3802b",
          "message": "fix: remove ambiguities (#16)",
          "timestamp": "2025-06-08T17:43:28+02:00",
          "tree_id": "1fb4ca8af85c3dc1ba027d637bd1f498ced2ff13",
          "url": "https://github.com/oameye/VanVleckRecursion.jl/commit/cea0869e430d5e7afd87fbccb5b1e4169bd3802b"
        },
        "date": 1749397554280,
        "tool": "julia",
        "benches": [
          {
            "name": "van Vleck expansion/Fifth order",
            "value": 1881600596,
            "unit": "ns",
            "extra": "gctime=11901980\nmemory=140334744\nallocs=1794987\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":50,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      }
    ]
  }
}