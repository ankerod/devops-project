import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
    const [items, setItems] = useState([]);
    const [newItem, setNewItem] = useState('');

    const fetchItems = async () => {
        try {
            const response = await fetch('http://127.0.0.1:8000/items');
            const data = await response.json();
            setItems(data);
        } catch (error) {
            console.error('Error to connect to API: ', error);
        }
    };

    useEffect(() => {
        fetchItems();
    }, []);

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!newItem) return;

        await fetch('http://127.0.0.1:8000/items', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ name: newItem }),
        });

        setNewItem('');
        fetchItems();
    };

    return (
        <div style={{ padding: '20px', fontFamily: 'Arial' }}>
            <h1>🛒 Shopping list</h1>

            <form onSubmit={handleSubmit} style={{ marginBottom: '20px' }}>
                <input
                    type="text"
                    value={newItem}
                    onChange={(e) => setNewItem(e.target.value)}
                    placeholder="type new item..."
                    style={{ padding: '10px', width: '200px' }}
                />
                <button
                    type="submit"
                    style={{ padding: '10px', marginLeft: '10px' }}
                >
                    Add
                </button>
            </form>

            <ul>
                {items.map((item, index) => (
                    <li
                        key={index}
                        style={{ fontSize: '18px', margin: '5px 0' }}
                    >
                        {item.name}
                    </li>
                ))}
            </ul>
        </div>
    );
}

export default App;
