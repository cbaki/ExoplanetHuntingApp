# combine_data.py
import pandas as pd
import os

print("🚀 VERİ SETLERİ BİRLEŞTİRİLİYOR...")

# Hata ayıklama modunda CSV'leri oku
dfs = []

# 1. Ana veri seti - hata ayıklama ile oku
print("📂 cumulative_2025.10.04_02.11.48.csv yükleniyor...")
try:
    # Önce hatanın olduğu satırı bulalım
    df1 = pd.read_csv('cumulative_2025.10.04_02.11.48.csv', on_bad_lines='skip')
    print(f"   ✅ {len(df1):,} kayıt yüklendi")
    dfs.append(df1)
except Exception as e:
    print(f"   ❌ Hata: {e}")
    # Alternatif yöntem
    try:
        df1 = pd.read_csv('cumulative_2025.10.04_02.11.48.csv', error_bad_lines=False)
        print(f"   ✅ {len(df1):,} kayıt yüklendi (hatalı satırlar atlandı)")
        dfs.append(df1)
    except:
        print("   ❌ Alternatif yöntem de başarısız")

# 2. K2 veri seti  
print("📂 k2pandc_2025.10.04_02.12.05.csv yükleniyor...")
try:
    df2 = pd.read_csv('k2pandc_2025.10.04_02.12.05.csv', on_bad_lines='skip')
    print(f"   ✅ {len(df2):,} kayıt yüklendi")
    dfs.append(df2)
except Exception as e:
    print(f"   ❌ Hata: {e}")

# 3. TOI veri seti
print("📂 TOI_2025.10.04_02.11.58.csv yükleniyor...")
try:
    df3 = pd.read_csv('TOI_2025.10.04_02.11.58.csv', on_bad_lines='skip')
    print(f"   ✅ {len(df3):,} kayıt yüklendi")
    dfs.append(df3)
except Exception as e:
    print(f"   ❌ Hata: {e}")

if not dfs:
    print("❌ Hiçbir CSV yüklenemedi!")
    exit()

# Ortak sütunları bul
print("\n🔍 ORTAK SÜTUNLAR BULUNUYOR...")
common_columns = set(dfs[0].columns)
for df in dfs[1:]:
    common_columns = common_columns.intersection(set(df.columns))

print(f"   🎯 {len(common_columns)} ortak sütun bulundu:")
for col in sorted(list(common_columns))[:15]:  # İlk 15'i göster
    print(f"      • {col}")

# Sadece ortak sütunları seçerek birleştir
combined_dfs = []
for i, df in enumerate(dfs):
    df_common = df[list(common_columns)].copy()
    combined_dfs.append(df_common)
    print(f"   📊 DataFrame {i+1}: {len(df_common):,} kayıt")

# Tümünü birleştir
print("\n🔄 VERİ SETLERİ BİRLEŞTİRİLİYOR...")
final_df = pd.concat(combined_dfs, ignore_index=True)
print(f"   ✅ TOPLAM: {len(final_df):,} kayıt")
print(f"   📈 SÜTUN: {final_df.shape[1]}")

# Gezegen sütununu bul
print("\n🪐 GEZEGEN SÜTUNU ARA...")
planet_columns = [col for col in final_df.columns 
                 if 'disposition' in col.lower() 
                 or 'koi' in col.lower() 
                 or 'tfopwg' in col.lower()
                 or 'planet' in col.lower()]

if planet_columns:
    for col in planet_columns:
        print(f"   🔍 {col}: {final_df[col].nunique()} farklı değer")
        if final_df[col].nunique() < 10:  # Sadece sınıflandırma sütunlarını göster
            print(f"      📊 {dict(final_df[col].value_counts())}")
else:
    print("   ❌ Açık gezegen sütunu bulunamadı")

# İlk birkaç kaydı göster
print("\n👀 İLK 3 KAYIT:")
print(final_df.head(3))

# Kaydet
print("\n💾 YENİ VERİ SETİ KAYDEDİLİYOR...")
final_df.to_csv('combined_exoplanet_data.csv', index=False)
print("   ✅ combined_exoplanet_data.csv kaydedildi")

print(f"\n🎉 İŞLEM TAMAMLANDI!")
print(f"   📁 Yeni veri seti: {len(final_df):,} kayıt")
print(f"   🎯 Kullanılabilir sütun: {final_df.shape[1]}")