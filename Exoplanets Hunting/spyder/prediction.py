# prediction.py
import joblib
import pandas as pd
import numpy as np
import os

class ExoplanetPredictor:
    def __init__(self, model_path="models/best_model.pkl", 
                 preprocessor_path="models/preprocessor.pkl",
                 feature_path="models/feature_list.pkl"):
        
        # Dosya kontrolü
        if not all(os.path.exists(p) for p in [model_path, preprocessor_path, feature_path]):
            print("❌ Model dosyaları bulunamadı! Önce modeli eğitin.")
            raise FileNotFoundError("Model dosyaları eksik")
            
        self.model = joblib.load(model_path)
        self.preprocessor = joblib.load(preprocessor_path)
        self.features = joblib.load(feature_path)
        print("✅ Tahmin edici başarıyla yüklendi!")
    
    def predict_single(self, input_data):
        """
        Tek bir gezegen adayı için tahmin yap
        """
        try:
            # Eksik özellikleri NaN ile doldur
            features_df = pd.DataFrame([input_data])
            for feature in self.features:
                if feature not in features_df.columns:
                    features_df[feature] = np.nan
            
            # Sadece gerekli özellikleri seç ve sırala
            features_df = features_df[self.features]
            
            # Ön işleme
            processed_data = self.preprocessor.transform(features_df)
            
            # Tahmin
            prediction = self.model.predict(processed_data)[0]
            probability = self.model.predict_proba(processed_data)[0][1]
            
            result = {
                'prediction': 'CONFIRMED PLANET' if prediction == 1 else 'FALSE POSITIVE',
                'confidence': float(probability),
                'probability_planet': float(probability),
                'probability_fp': float(1 - probability),
                'success': True
            }
            
            print(f"\n🎯 TAHMİN SONUCU:")
            print(f"   Durum: {result['prediction']}")
            print(f"   Güven Skoru: {result['confidence']:.2%}")
            print(f"   Gezegen Olasılığı: {result['probability_planet']:.2%}")
            
            return result
            
        except Exception as e:
            print(f"❌ Tahmin hatası: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def predict_batch(self, csv_file_path):
        """
        CSV dosyasından toplu tahmin yap
        """
        try:
            if not os.path.exists(csv_file_path):
                print(f"❌ CSV dosyası bulunamadı: {csv_file_path}")
                return None
                
            df = pd.read_csv(csv_file_path)
            results = []
            
            print(f"📁 {len(df)} aday analiz ediliyor...")
            
            for idx, row in df.iterrows():
                try:
                    result = self.predict_single(row.to_dict())
                    result['id'] = idx
                    results.append(result)
                    
                    if (idx + 1) % 10 == 0:
                        print(f"   ⏳ {idx + 1}/{len(df)} tamamlandı...")
                        
                except Exception as e:
                    print(f"   ❌ Satır {idx} hatası: {e}")
            
            results_df = pd.DataFrame(results)
            
            # İstatistikleri yazdır
            confirmed_count = (results_df['prediction'] == 'CONFIRMED PLANET').sum()
            print(f"\n📊 TOPLU TAHMİN SONUÇLARI:")
            print(f"   ✅ Gezegen Tespit Edilen: {confirmed_count}")
            print(f"   ❌ Sahte Pozitif: {len(results_df) - confirmed_count}")
            print(f"   📈 Gezegen Oranı: {confirmed_count/len(results_df):.2%}")
            
            return results_df
            
        except Exception as e:
            print(f"❌ Toplu tahmin hatası: {e}")
            return None

# Demo fonksiyonları
def demo_single_prediction():
    """Tek bir tahmin demo"""
    print("\n" + "="*50)
    print("🧪 TEK TAHMİN DEMOSU")
    print("="*50)
    
    try:
        predictor = ExoplanetPredictor()
        
        # Örnek gezegen adayları
        sample_candidates = [
            {
                'period': 15.2, 'duration': 3.1, 'depth': 1800,
                'ror': 0.04, 'prad': 1.5, 'srad': 0.9, 'srho': 1.3,
                'kepmag': 11.8, 'model_snr': 20.5, 'insol': 850, 'teq': 1550
            },
            {
                'period': 5.2, 'duration': 1.2, 'depth': 500,
                'ror': 0.08, 'prad': 0.5, 'srad': 0.6, 'srho': 2.1,
                'kepmag': 15.0, 'model_snr': 8.2, 'insol': 2000, 'teq': 1800
            }
        ]
        
        for i, candidate in enumerate(sample_candidates, 1):
            print(f"\n🔭 ADAY {i} ANALİZİ:")
            print("-" * 30)
            result = predictor.predict_single(candidate)
            
        return True
        
    except Exception as e:
        print(f"❌ Demo hatası: {e}")
        return False

def demo_batch_prediction():
    """Toplu tahmin demo"""
    print("\n" + "="*50)
    print("📊 TOPLU TAHMİN DEMOSU")
    print("="*50)
    
    try:
        # Örnek CSV oluştur
        sample_data = {
            'period': [12.5, 8.3, 25.1, 4.7, 15.8],
            'duration': [2.8, 1.9, 4.2, 1.1, 3.3],
            'depth': [2000, 1500, 800, 2500, 1200],
            'ror': [0.03, 0.05, 0.02, 0.07, 0.04],
            'prad': [1.8, 1.2, 2.5, 0.8, 1.6],
            'srad': [1.1, 0.8, 1.3, 0.6, 0.9],
            'srho': [1.2, 1.5, 0.9, 1.8, 1.1],
            'kepmag': [13.0, 12.2, 14.5, 11.8, 12.8],
            'model_snr': [18.5, 15.2, 22.1, 9.8, 19.3],
            'insol': [1200, 1800, 800, 2200, 950],
            'teq': [1400, 1600, 1200, 1900, 1350]
        }
        
        df = pd.DataFrame(sample_data)
        df.to_csv('sample_candidates.csv', index=False)
        print("✅ Örnek CSV dosyası oluşturuldu: sample_candidates.csv")
        
        predictor = ExoplanetPredictor()
        results = predictor.predict_batch('sample_candidates.csv')
        
        if results is not None:
            # Sonuçları kaydet
            results.to_csv('prediction_results.csv', index=False)
            print("✅ Tahmin sonuçları kaydedildi: prediction_results.csv")
            
        return True
        
    except Exception as e:
        print(f"❌ Toplu tahmin demo hatası: {e}")
        return False

if __name__ == "__main__":
    print("🚀 EXOPLANET PREDICTION SYSTEM")
    
    # Demo çalıştır
    success1 = demo_single_prediction()
    success2 = demo_batch_prediction()
    
    if success1 and success2:
        print("\n🎉 Tüm demolar başarıyla tamamlandı!")
    else:
        print("\n⚠️  Bazı demolarda hata oluştu!")