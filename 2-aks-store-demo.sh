#!/bin/bash
set -e

kubectl config use-context aks-standard
helm install aks-store-demo charts/aks-store-demo -n aks-store

kubectl config use-context aks-automatic
helm install aks-store-demo charts/aks-store-demo -n aks-store