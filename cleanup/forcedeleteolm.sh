#!/bin/bash
BAD_NAMESPACE=olm
kubectl get namespace "$BAD_NAMESPACE" -o json   | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"   | kubectl replace --raw /api/v1/namespaces/$BAD_NAMESPACE/finalize -f -
