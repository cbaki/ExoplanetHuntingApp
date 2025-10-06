# mobile_api.py - BÖLÜM 1
from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import pandas as pd
import numpy as np
import os
import logging
from datetime import datetime
import math

# Logging ayarı
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Global değişkenler
model = None
preprocessor = None
features = None

def load_model():
    """Modeli yükle"""
    global model, preprocessor, features
    try:
        model_path = "models/best_model.pkl"
        preprocessor_path = "models/preprocessor.pkl"
        feature_path = "models/feature_list.pkl"
        
        if not all(os.path.exists(p) for p in [model_path, preprocessor_path, feature_path]):
            logger.error("❌ Model dosyaları bulunamadı!")
            return False
            
        model = joblib.load(model_path)
        preprocessor = joblib.load(preprocessor_path)
        features = joblib.load(feature_path)
        
        logger.info("✅ Model API için başarıyla yüklendi!")
        logger.info(f"📊 Yüklenen özellikler: {features}")
        return True
    except Exception as e:
        logger.error(f"❌ Model yükleme hatası: {e}")
        return False

# Modeli başlangıçta yükle
print("🔄 Model yükleniyor...")
load_model()

def calculate_derived_features(data):
    """YENİ: Türetilmiş özellikler hesapla"""
    try:
        derived = {}
        
        # 1. Yaşanabilir bölge mesafesi
        star_luminosity = (data.get('srad', 1) ** 2) * ((data.get('teq', 288) / 5778) ** 4)
        habitable_zone_inner = math.sqrt(star_luminosity / 1.1)
        habitable_zone_outer = math.sqrt(star_luminosity / 0.53)
        
        # 2. Gezegenin yaşanabilir bölgede olup olmadığı
        planet_au = (data.get('period', 365) ** (2/3)) * (data.get('srad', 1) ** (-1/3))
        in_habitable_zone = habitable_zone_inner <= planet_au <= habitable_zone_outer
        
        # 3. Gezegen yoğunluğu tahmini
        if data.get('prad', 0) > 0:
            if data.get('prad', 0) < 1.5:
                density = 5.5  # Kayalık gezegen
            elif data.get('prad', 0) < 4:
                density = 2.0  # Mini-Neptün
            else:
                density = 1.3  # Gaz devi
        else:
            density = 0
            
        # 4. Yörünge hızı (km/s)
        orbital_velocity = 30 * math.sqrt(1/data.get('period', 365)) * math.sqrt(data.get('srad', 1))
        
        # 5. Geçiş sinyal gücü
        transit_signal_strength = (data.get('depth', 0) / 10000) * (data.get('model_snr', 1) / 10)
        
        derived.update({
            'habitable_zone_inner': round(habitable_zone_inner, 3),
            'habitable_zone_outer': round(habitable_zone_outer, 3),
            'planet_semi_major_axis': round(planet_au, 3),
            'in_habitable_zone': in_habitable_zone,
            'estimated_density': round(density, 2),
            'orbital_velocity': round(orbital_velocity, 2),
            'transit_signal_strength': round(transit_signal_strength, 3),
            'star_luminosity': round(star_luminosity, 3)
        })
        
        logger.info(f"📈 Türetilmiş özellikler: {derived}")
        return derived
    except Exception as e:
        logger.error(f"❌ Türetilmiş özellik hatası: {e}")
        return {}

def get_star_info(teq, srad, kepmag):
    """Yıldız bilgilerini tahmin et"""
    try:
        if teq > 10000:
            star_type = "O-tipi (Mavi dev)"
        elif teq > 7500:
            star_type = "B-tipi (Beyaz-mavi)"
        elif teq > 6000:
            star_type = "A-tipi (Beyaz)"
        elif teq > 5200:
            star_type = "F-tipi (Sarı-beyaz)"
        elif teq > 3700:
            star_type = "G-tipi (Sarı cüce - Güneş benzeri)"
        elif teq > 2400:
            star_type = "K-tipi (Turuncu cüce)"
        else:
            star_type = "M-tipi (Kırmızı cüce)"
        
        star_mass = round(srad ** 0.8, 2)
        
        if star_type.startswith("O") or star_type.startswith("B"):
            age = "Genç (<100 milyon yıl)"
        elif star_type.startswith("A") or star_type.startswith("F"):
            age = "Orta (100 milyon - 2 milyar yıl)"
        elif star_type.startswith("G"):
            age = "Orta-yaşlı (2-8 milyar yıl)"
        else:
            age = "Yaşlı (>8 milyar yıl)"
        
        if kepmag < 8:
            brightness = "Çok parlak"
        elif kepmag < 12:
            brightness = "Parlak" 
        elif kepmag < 16:
            brightness = "Orta parlaklık"
        else:
            brightness = "Sönük"
        
        return {
            'type': star_type,
            'mass': f"{star_mass} M☉",
            'age': age,
            'brightness': brightness,
            'radius': f"{srad} R☉",
            'temperature': f"{int(teq)} K"
        }
    except Exception as e:
        logger.error(f"❌ Yıldız bilgisi hatası: {e}")
        return {
            'type': "Bilinmiyor", 'mass': "Bilinmiyor", 'age': "Bilinmiyor", 
            'brightness': "Bilinmiyor", 'radius': "Bilinmiyor", 'temperature': "Bilinmiyor"
        }

def predict_planet_type(data, derived_features):
    """YENİ: Gezegen tipini tahmin et"""
    try:
        prad = data.get('prad', 0)
        teq = data.get('teq', 0)
        in_habitable = derived_features.get('in_habitable_zone', False)
        density = derived_features.get('estimated_density', 0)
        
        if prad < 1.2:
            if in_habitable and 200 < teq < 400:
                return "Dünya-benzeri (Potansiyel yaşanabilir)"
            elif teq > 500:
                return "Sıcak Dünya"
            else:
                return "Kayalık gezegen"
        elif prad < 3.0:
            if density > 3:
                return "Süper-Dünya"
            else:
                return "Mini-Neptün"
        elif prad < 10:
            return "Gaz Devi (Jüpiter-benzeri)"
        else:
            return "Sıcak Jüpiter"
    except Exception as e:
        logger.error(f"❌ Gezegen tipi tahmini hatası: {e}")
        return "Bilinmiyor"

def generate_simulation_data(data, derived_features):
    """YENİ: Işık eğrisi simülasyonu verisi oluştur"""
    try:
        period = data.get('period', 10)
        duration = data.get('duration', 3)
        depth = data.get('depth', 1000)
        
        time_points = np.linspace(0, period, 100)
        light_curve = []
        
        for t in time_points:
            transit_phase = (t % period) / period
            if 0.45 <= transit_phase <= 0.55:
                brightness = 1 - (depth / 1000000)
            else:
                brightness = 1.0
                
            light_curve.append({
                'time': round(t, 2),
                'brightness': round(brightness, 4),
                'phase': round(transit_phase, 3)
            })
        
        return {
            'light_curve': light_curve,
            'transit_center': period / 2,
            'transit_duration': duration,
            'depth_percentage': round(depth / 10000, 2)
        }
    except Exception as e:
        logger.error(f"❌ Simülasyon verisi hatası: {e}")
        return {'light_curve': [], 'error': str(e)}

@app.route('/api/predict', methods=['POST'])
def predict_exoplanet():
    """Gezegen tahmini yap - GÜNCELLENDİ"""
    try:
        if model is None:
            if not load_model():
                return jsonify({
                    'success': False,
                    'error': 'Model yüklenemedi. Lütfen backend kontrol edin.'
                }), 500
        
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': 'Geçersiz JSON verisi'
            }), 400
        
        logger.info(f"📱 Mobil tahmin isteği alındı: {datetime.now()}")
        
        # YENİ: Türetilmiş özellikler
        derived_features = calculate_derived_features(data)
        
        # Girdiyi işle
        input_df = pd.DataFrame([data])
        for feature in features:
            if feature not in input_df.columns:
                input_df[feature] = np.nan
        input_df = input_df[features]
        
        # Tahmin yap
        processed_data = preprocessor.transform(input_df)
        prediction = model.predict(processed_data)[0]
        probability = model.predict_proba(processed_data)[0][1]
        
        is_planet = prediction == 1
        confidence = float(probability)
        
        # YENİ: Gezegen tipini tahmin et
        planet_type = predict_planet_type(data, derived_features)
        
        # Mesajı belirle
        if is_planet:
            if confidence > 0.8:
                message = f"🎉 YÜKSEK GÜVENİLİRLİKLE {planet_type.upper()} TESPİT EDİLDİ!"
            elif confidence > 0.6:
                message = f"✅ {planet_type} tespit edildi!"
            else:
                message = f"⚠️ Zayıf {planet_type.lower()} sinyali tespit edildi"
        else:
            if confidence < 0.3:
                message = "❌ GÜÇLÜ ŞEKİLDE SAHTE POZİTİF"
            elif confidence < 0.5:
                message = "❌ Sahte pozitif olabilir"
            else:
                message = "⚠️ Zayıf sahte pozitif sinyali"
        
        # Yıldız bilgilerini hesapla
        star_info = get_star_info(
            data.get('teq', 0),
            data.get('srad', 0), 
            data.get('kepmag', 0)
        )
        
        response = {
            'success': True,
            'prediction': 'CONFIRMED_PLANET' if is_planet else 'FALSE_POSITIVE',
            'confidence': confidence,
            'probability_planet': confidence,
            'probability_fp': float(1 - confidence),
            'message': message,
            'timestamp': datetime.now().isoformat(),
            'feature_analysis': get_feature_analysis(data),
            'star_info': star_info,
            # YENİ ÖZELLİKLER:
            'planet_type': planet_type,
            'derived_features': derived_features,
            'simulation_data': generate_simulation_data(data, derived_features)
        }
        
        logger.info(f"📊 Tahmin sonucu: {response['prediction']} (Güven: {confidence:.2%}, Tip: {planet_type})")
        logger.info(f"⭐ Yıldız bilgisi: {star_info['type']}")
        
        return jsonify(response)
        
    except Exception as e:
        logger.error(f"❌ Tahmin hatası: {e}")
        return jsonify({
            'success': False,
            'error': f'Tahmin yapılamadı: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }), 500
    
    
# mobile_api.py - BÖLÜM 2
def get_feature_analysis(input_data):
    """Özellik analizi yap"""
    analysis = {}
    
    try:
        # Örnek analiz kuralları
        if 'period' in input_data and input_data['period'] is not None:
            period = input_data['period']
            if period > 100:
                analysis['period'] = 'Uzun yörünge periyodu - Gaz devi olabilir'
            elif period < 10:
                analysis['period'] = 'Kısa yörünge periyodu - Sıcak gezegen olabilir'
            else:
                analysis['period'] = 'Normal yörünge periyodu'
        
        if 'prad' in input_data and input_data['prad'] is not None:
            prad = input_data['prad']
            if prad > 2:
                analysis['prad'] = 'Büyük gezegen - Gaz devi'
            elif prad < 1:
                analysis['prad'] = 'Küçük gezegen - Kayalık olabilir'
            else:
                analysis['prad'] = 'Dünya benzeri gezegen'
        
        if 'teq' in input_data and input_data['teq'] is not None:
            teq = input_data['teq']
            if teq > 1000:
                analysis['teq'] = 'Yüksek sıcaklık - Yaşanabilir bölge dışı'
            elif teq < 273:
                analysis['teq'] = 'Düşük sıcaklık - Soğuk gezegen'
            else:
                analysis['teq'] = 'Orta sıcaklık - Potansiyel yaşanabilir bölge'
        
        if 'depth' in input_data and input_data['depth'] is not None:
            depth = input_data['depth']
            if depth > 2000:
                analysis['depth'] = 'Derin geçiş - Büyük gezegen'
            elif depth < 500:
                analysis['depth'] = 'Sığ geçiş - Küçük gezegen'
        
    except Exception as e:
        logger.error(f"❌ Feature analysis hatası: {e}")
        analysis['error'] = 'Özellik analizi yapılamadı'
    
    return analysis

@app.route('/api/features', methods=['GET'])
def get_features():
    """Mobil uygulama için gerekli özellik listesini döndür"""
    try:
        if features is None:
            if not load_model():
                return jsonify({
                    'success': False,
                    'error': 'Model yüklenemedi'
                }), 500
            
        feature_descriptions = {
            'period': 'Yörünge periyodu (gün) - Gezegenin yıldız etrafındaki dönüş süresi',
            'duration': 'Geçiş süresi (saat) - Yıldız önünden geçiş süresi',
            'depth': 'Geçiş derinliği (ppm) - Işık eğrisindeki azalma miktarı',
            'ror': 'Yarıçap oranı - Gezegen/Yıldız yarıçap oranı',
            'prad': 'Gezegen yarıçapı (Dünya yarıçapı)',
            'srad': 'Yıldız yarıçapı (Güneş yarıçapı)',
            'srho': 'Yıldız yoğunluğu (g/cm³)',
            'kepmag': 'Yıldız parlaklığı - Kepler büyüklüğü',
            'model_snr': 'Sinyal-gürültü oranı - Sinyal kalitesi',
            'insol': 'Güneş ışınımı - Yıldızdan alınan enerji',
            'teq': 'Denge sıcaklığı (K) - Gezegenin tahmini sıcaklığı'
        }
        
        features_with_desc = []
        for feature in features:
            features_with_desc.append({
                'name': feature,
                'description': feature_descriptions.get(feature, 'Açıklama bulunamadı'),
                'required': True
            })
        
        return jsonify({
            'success': True,
            'features': features_with_desc,
            'count': len(features),
            'model_info': 'Exoplanet Detection Model v1.0'
        })
        
    except Exception as e:
        logger.error(f"❌ Features endpoint hatası: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """Sağlık kontrolü"""
    model_status = model is not None and preprocessor is not None and features is not None
    
    return jsonify({
        'status': 'healthy' if model_status else 'degraded',
        'model_loaded': model_status,
        'timestamp': datetime.now().isoformat(),
        'message': 'Exoplanet Detection API' if model_status else 'API çalışıyor ama model yüklenemedi',
        'endpoints': {
            'predict': '/api/predict (POST)',
            'features': '/api/features (GET)',
            'health': '/api/health (GET)'
        }
    })

@app.route('/api/batch_predict', methods=['POST'])
def batch_predict():
    """Toplu tahmin için (CSV dosyası)"""
    try:
        if model is None:
            if not load_model():
                return jsonify({
                    'success': False,
                    'error': 'Model yüklenemedi'
                }), 500
        
        if 'file' not in request.files:
            return jsonify({
                'success': False,
                'error': 'Dosya yüklenmedi'
            }), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({
                'success': False,
                'error': 'Dosya seçilmedi'
            }), 400
        
        if not file.filename.endswith('.csv'):
            return jsonify({
                'success': False,
                'error': 'Sadece CSV dosyaları kabul edilir'
            }), 400
        
        # CSV'yi oku
        df = pd.read_csv(file)
        logger.info(f"📁 Toplu tahmin için {len(df)} kayıt yüklendi")
        
        results = []
        for idx, row in df.iterrows():
            try:
                # Her satır için tahmin yap
                input_df = pd.DataFrame([row.to_dict()])
                
                for feature in features:
                    if feature not in input_df.columns:
                        input_df[feature] = np.nan
                
                input_df = input_df[features]
                processed_data = preprocessor.transform(input_df)
                
                prediction = model.predict(processed_data)[0]
                probability = model.predict_proba(processed_data)[0][1]
                
                results.append({
                    'id': idx,
                    'prediction': 'CONFIRMED_PLANET' if prediction == 1 else 'FALSE_POSITIVE',
                    'confidence': float(probability),
                    'success': True
                })
                
            except Exception as e:
                results.append({
                    'id': idx,
                    'success': False,
                    'error': str(e)
                })
        
        # İstatistikler
        successful = [r for r in results if r['success']]
        planets = [r for r in successful if r['prediction'] == 'CONFIRMED_PLANET']
        
        stats = {
            'total_records': len(df),
            'successful_predictions': len(successful),
            'planets_detected': len(planets),
            'false_positives': len(successful) - len(planets),
            'planet_ratio': len(planets) / len(successful) if successful else 0
        }
        
        return jsonify({
            'success': True,
            'results': results,
            'statistics': stats,
            'message': f"{len(planets)} gezegen tespit edildi"
        })
        
    except Exception as e:
        logger.error(f"❌ Toplu tahmin hatası: {e}")
        return jsonify({
            'success': False,
            'error': f'Toplu tahmin yapılamadı: {str(e)}'
        }), 500

@app.route('/api/simulation/light_curve', methods=['POST'])
def generate_light_curve():
    """YENİ: Detaylı ışık eğrisi simülasyonu"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'error': 'Geçersiz veri'}), 400
        
        period = data.get('period', 10)
        duration = data.get('duration', 3)
        depth = data.get('depth', 1000)
        
        # Detaylı ışık eğrisi
        time_points = np.linspace(0, period * 2, 200)  # 2 döngü
        light_curve = []
        
        for t in time_points:
            phase = (t % period) / period
            
            # Gerçekçi geçiş profili
            if 0.5 - (duration/period)/2 <= phase <= 0.5 + (duration/period)/2:
                # Geçiş merkezine uzaklık
                distance_from_center = abs(phase - 0.5) / ((duration/period)/2)
                
                # Yumuşak geçiş eğrisi
                if distance_from_center < 0.8:
                    brightness_drop = depth / 1000000
                else:
                    # Kenarlarda yumuşak geçiş
                    brightness_drop = (depth / 1000000) * (1 - distance_from_center)
                
                brightness = 1 - brightness_drop
            else:
                brightness = 1.0
                
            light_curve.append({
                'time': round(t, 2),
                'brightness': round(brightness, 6),
                'phase': round(phase, 3),
                'in_transit': phase >= 0.5 - (duration/period)/2 and phase <= 0.5 + (duration/period)/2
            })
        
        return jsonify({
            'success': True,
            'light_curve': light_curve,
            'parameters': {
                'period': period,
                'duration': duration,
                'depth': depth,
                'data_points': len(light_curve)
            }
        })
        
    except Exception as e:
        logger.error(f"❌ Işık eğrisi hatası: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/planet/comparison', methods=['POST'])
def compare_with_earth():
    """YENİ: Dünya ile karşılaştırma"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'error': 'Geçersiz veri'}), 400
        
        prad = data.get('prad', 1.0)
        period = data.get('period', 365)
        teq = data.get('teq', 288)
        
        # Dünya değerleri
        earth_radius = 1.0
        earth_year = 365
        earth_temperature = 288
        
        comparisons = {
            'size_ratio': round(prad / earth_radius, 2),
            'year_ratio': round(period / earth_year, 2),
            'temperature_ratio': round(teq / earth_temperature, 2),
            'size_description': get_size_description(prad),
            'orbital_description': get_orbital_description(period),
            'temperature_description': get_temperature_description(teq)
        }
        
        return jsonify({
            'success': True,
            'comparisons': comparisons,
            'earth_reference': {
                'radius': earth_radius,
                'orbital_period': earth_year,
                'temperature': earth_temperature
            }
        })
        
    except Exception as e:
        logger.error(f"❌ Karşılaştırma hatası: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

def get_size_description(radius):
    """Gezegen boyutu açıklaması"""
    if radius < 0.8:
        return "Dünya'dan küçük"
    elif radius < 1.2:
        return "Dünya boyutunda"
    elif radius < 2.0:
        return "Süper-Dünya"
    elif radius < 6.0:
        return "Mini-Neptün"
    else:
        return "Gaz Devi"

def get_orbital_description(period):
    """Yörünge periyodu açıklaması"""
    if period < 10:
        return "Çok kısa yörünge"
    elif period < 50:
        return "Kısa yörünge"
    elif period < 200:
        return "Orta yörünge"
    elif period < 500:
        return "Uzun yörünge"
    else:
        return "Çok uzun yörünge"

def get_temperature_description(teq):
    """Sıcaklık açıklaması"""
    if teq < 150:
        return "Buz gibi"
    elif teq < 250:
        return "Soğuk"
    elif teq < 350:
        return "Ilıman"
    elif teq < 500:
        return "Sıcak"
    else:
        return "Aşırı sıcak"

@app.route('/')
def home():
    """Ana sayfa"""
    model_status = model is not None
    
    return jsonify({
        'message': '🚀 Exoplanet Detection API - NASA Space Apps Challenge',
        'version': '2.0',  # Güncellendi
        'model_loaded': model_status,
        'endpoints': {
            'predict': '/api/predict (POST) - Tekil tahmin',
            'batch_predict': '/api/batch_predict (POST) - Toplu tahmin',
            'features': '/api/features (GET) - Özellik listesi',
            'health': '/api/health (GET) - Sağlık kontrolü',
            'simulation': '/api/simulation/light_curve (POST) - Işık eğrisi simülasyonu',  # YENİ
            'comparison': '/api/planet/comparison (POST) - Dünya karşılaştırması'  # YENİ
        },
        'new_features': [  # YENİ
            'Gezegen tipi tahmini',
            'Yaşanabilir bölge analizi', 
            'Işık eğrisi simülasyonu',
            'Dünya karşılaştırması',
            'Türetilmiş özellikler'
        ],
        'example_request': {
            'period': 15.2,
            'duration': 3.1,
            'depth': 1800,
            'ror': 0.04,
            'prad': 1.5,
            'srad': 0.9,
            'srho': 1.3,
            'kepmag': 11.8,
            'model_snr': 20.5,
            'insol': 850,
            'teq': 1550
        }
    })

# Hata sayfaları
@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'error': 'Endpoint bulunamadı',
        'available_endpoints': {
            'GET /': 'Ana sayfa',
            'POST /api/predict': 'Gezegen tahmini',
            'POST /api/simulation/light_curve': 'Işık eğrisi simülasyonu',
            'POST /api/planet/comparison': 'Dünya karşılaştırması',
            'GET /api/features': 'Özellik listesi',
            'GET /api/health': 'Sağlık kontrolü'
        }
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'success': False,
        'error': 'Sunucu hatası'
    }), 500

if __name__ == '__main__':
    print("🚀 EXOPLANET DETECTION API v2.0")
    print("=" * 50)
    
    # Modeli yükle
    if model is not None:
        print("✅ Model başarıyla yüklendi!")
        print("🌐 API başlatılıyor: http://localhost:5000")
        print("\n📋 YENİ ENDPOINT'LER:")
        print("   POST /api/simulation/light_curve - Işık eğrisi simülasyonu")
        print("   POST /api/planet/comparison     - Dünya karşılaştırması")
        print("\n🎯 YENİ ÖZELLİKLER:")
        print("   • Gezegen tipi tahmini")
        print("   • Yaşanabilir bölge analizi") 
        print("   • Işık eğrisi görselleştirme")
        print("   • Dünya karşılaştırması")
        print("   • Türetilmiş bilimsel özellikler")
        print("\n📱 Mobil uygulamanızı http://localhost:5000 adresine bağlayın")
        print("💡 Test etmek için tarayıcıda açın: http://localhost:5000/api/health")
        
        # Debug modunu kapatarak çalıştır
        app.run(host='0.0.0.0', port=5000, debug=False)
    else:
        print("❌ Model yüklenemedi! Lütfen model dosyalarını kontrol edin.")
        print("   Gerekli dosyalar:")
        print("   - models/best_model.pkl")
        print("   - models/preprocessor.pkl") 
        print("   - models/feature_list.pkl")
        print("\n🔧 Çözüm: Önce modeli eğitin: python exoplanet_tabular_pipeline.py")