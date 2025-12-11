from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

inventory = []


class Item(BaseModel):
    name: str


@app.get("/")
def read_root():
    return {"message": "API is working!"}


@app.get("/items", response_model=List[Item])
def get_items():
    return inventory


@app.post("/items")
def add_item(item: Item):
    inventory.append(item)
    return {"message": "Item has added!", "item": item}
