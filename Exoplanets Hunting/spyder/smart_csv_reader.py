# smart_csv_reader.py
import pandas as pd
import os

print("🎯 AKILLI CSV OKUYUCU BAŞLATILDI...")

def smart_read_nasa_csv(filename):
    """NASA CSV'lerini akıllıca oku"""
    print(f"\n📂 {filename} analiz ediliyor...")
    
    try:
        # Tüm satırları oku
        with open(filename, 'r', encoding='utf-8') as f:
            lines = [line.strip() for line in f.readlines() if line.strip()]
        
        print(f"   📊 Toplam satır: {len(lines)}")
        
        # Header'ı bul (# ile başlayan ama veri içeren satır)
        header_line = None
        data_start = 0
        
        for i, line in enumerate(lines):
            if line.startswith('#'):
                # Bu bir header satırı olabilir
                clean_line = line[1:].strip()  # # işaretini kaldır
                if clean_line and not clean_line.startswith('This file'):
                    # Virgülle ayrılmış sütun isimlerini kontrol et
                    if ',' in clean_line and len(clean_line.split(',')) > 5:
                        header_line = clean_line
                        data_start = i + 1
                        print(f"   🎯 Header bulundu (satır {i+1})")
                        break
        
        if header_line:
            print(f"   🏷️  Header: {header_line[:80]}...")
            print(f"   📝 Veri başlangıcı: satır {data_start+1}")
            
            # Veri satırlarını al
            data_lines = lines[data_start:]
            print(f"   📈 Veri satırı: {len(data_lines)}")
            
            # Geçici dosya oluştur
            temp_file = f"temp_{os.path.basename(filename)}"
            with open(temp_file, 'w', encoding='utf-8') as f:
                f.write(header_line + '\n')
                f.write('\n'.join(data_lines))
            
            # CSV'yi oku
            df = pd.read_csv(temp_file)
            
            # Geçici dosyayı sil
            os.remove(temp_file)
            
            print(f"   ✅ {len(df)} kayıt yüklendi")
            print(f"   🎯 Sütun sayısı: {df.shape[1]}")
            return df
        else:
            print("   ❌ Header bulunamadı, manuel deneme...")
            # Manuel deneme - ilk 10 satırı göster
            print("   👀 İlk 10 satır:")
            for i in range(min(10, len(lines))):
                print(f"      {i+1}: {lines[i][:100]}...")
            return None
            
    except Exception as e:
        print(f"   ❌ Hata: {e}")
        return None

# Alternatif yöntem - pandas ile direkt okuma
def direct_read_csv(filename):
    """CSV'yi direkt okumayı dene"""
    print(f"\n📂 {filename} direkt okunuyor...")
    
    try:
        # Farklı parametrelerle dene
        attempts = [
            {'comment': '#'},
            {'skiprows': lambda x: x.startswith('#')},
            {'skiprows': 100},  # İlk 100 satırı atla
            {'skiprows': 500},  # İlk 500 satırı atla
        ]
        
        for i, params in enumerate(attempts):
            try:
                print(f"   Deneme {i+1}: {params}")
                df = pd.read_csv(filename, **params)
                if len(df) > 0:
                    print(f"   ✅ {len(df)} kayıt yüklendi")
                    print(f"   🎯 Sütun: {df.shape[1]}")
                    print(f"   🏷️  İlk sütunlar: {list(df.columns[:3])}")
                    return df
            except Exception as e:
                print(f"   ❌ Başarısız: {e}")
                continue
                
        return None
    except Exception as e:
        print(f"   ❌ Tüm denemeler başarısız: {e}")
        return None

# Ana işlem
print("=" * 60)
files = ['cumulative_2025.10.04_02.11.48.csv', 
         'k2pandc_2025.10.04_02.12.05.csv', 
         'TOI_2025.10.04_02.11.58.csv']

dfs = []

for file in files:
    # Önce akıllı okumayı dene
    df = smart_read_nasa_csv(file)
    
    # Başarısız olursa direkt okumayı dene
    if df is None:
        df = direct_read_csv(file)
    
    if df is not None:
        dfs.append(df)
        print(f"   💾 {file} başarıyla yüklendi!\n")
    else:
        print(f"   ❌ {file} yüklenemedi!\n")

if dfs:
    print("🎉 BAŞARILI! YÜKLENEN VERİ SETLERİ:")
    for i, df in enumerate(dfs):
        print(f"\n📁 Veri Seti {i+1}:")
        print(f"   📊 Kayıt: {len(df):,}")
        print(f"   🎯 Sütun: {df.shape[1]}")
        print(f"   🏷️  İlk 5 sütun: {list(df.columns[:5])}")
        
        # Gezegen sütunlarını ara
        planet_keywords = ['disposition', 'koi', 'planet', 'tfopwg', 'candidate']
        planet_cols = [col for col in df.columns 
                      if any(keyword in col.lower() for keyword in planet_keywords)]
        
        if planet_cols:
            print(f"   🪐 Gezegen sütunları: {planet_cols}")
            for col in planet_cols[:2]:  # İlk 2 sütunu göster
                unique_vals = df[col].dropna().unique()
                print(f"      🔍 {col}: {len(unique_vals)} değer")
                if len(unique_vals) <= 5:
                    print(f"         📊 {list(unique_vals)}")
        
        # İlk kaydı göster
        print(f"   👀 İlk kayıt:")
        first_row = df.iloc[0]
        for col in df.columns[:3]:
            print(f"      {col}: {first_row[col]}")
            
else:
    print("❌ HİÇBİR DOSYA YÜKLENEMEDİ!")