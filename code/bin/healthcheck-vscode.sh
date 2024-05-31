#!/bin/bash
curl -s -o /dev/null -w "%{http_code}" localhost:8000
