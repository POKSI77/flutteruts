import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional

# --- Konfigurasi Firebase ---

# 1. Muat Kredensial Admin
# Ini mengasumsikan 'serviceAccountKey.json' ada di folder 'poksi/'
# Seperti yang terlihat di screenshot Anda, path 'poksi/serviceAccountKey.json' sudah benar.
try:
    cred = credentials.Certificate("serviceAccountKey.json")
except FileNotFoundError:
    print("KESALAHAN: File 'poksi/serviceAccountKey.json' tidak ditemukan.")
    print("Silakan unduh dari Firebase Console dan letakkan di folder 'poksi'.")
    exit()

# 2. Inisialisasi Aplikasi Firebase
firebase_admin.initialize_app(cred)

# 3. Dapatkan Klien Database Firestore
db = firestore.client()

# --- Definisi Aplikasi FastAPI ---

# 4. Buat aplikasi FastAPI Anda
app = FastAPI()

# --- Model Data (Opsional tapi bagus) ---
# Ini membantu FastAPI memvalidasi data
class Book(BaseModel):
    title: str
    author: str
    description: str
    imageUrl: str
    price: float
    type: Optional[str] = 'normal' # Default 'normal' jika tidak diisi
    bonusPrice: Optional[float] = 0  # Default 0 jika tidak diisi
    discountPercentage: Optional[int] = 0  # int untuk persentase diskon

# --- Endpoint API Anda ---

@app.get("/")
def read_root():
    """Endpoint dasar untuk memeriksa apakah API berjalan."""
    return {"message": "Selamat datang di Poksi API!"}

@app.get("/books")
async def get_books():
    """Mengambil semua buku dari koleksi 'books' di Firestore."""
    try:
        books_ref = db.collection('books')
        docs = books_ref.stream()

        books_list = []
        for doc in docs:
            book_data = doc.to_dict()
            book_data['id'] = doc.id  # Tambahkan ID dokumen ke data
            books_list.append(book_data)
            
        return books_list
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/books")
async def create_book(book: Book):
    """Menambahkan buku baru ke koleksi 'books'."""
    try:
        # Pydantic model diubah kembali ke dict untuk Firestore
        book_data = book.dict()
        
        # Tambahkan dokumen baru dengan ID yang dibuat otomatis
        doc_ref = db.collection('books').add(book_data)
        
        return {"message": "Buku berhasil ditambahkan", "id": doc_ref[1].id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))