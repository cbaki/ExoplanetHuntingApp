# visualization.py
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from sklearn.metrics import confusion_matrix, roc_curve, roc_auc_score, precision_recall_curve
import joblib
import pandas as pd
import os

plt.rcParams['font.family'] = 'DejaVu Sans'  # Türkçe karakter desteği

class ExoplanetVisualizer:
    def __init__(self, model_path="models/best_model.pkl", 
                 preprocessor_path="models/preprocessor.pkl",
                 feature_path="models/feature_list.pkl"):
        
        # Dosya kontrolü
        if not os.path.exists(model_path):
            print(f"⚠️  Model dosyası bulunamadı: {model_path}")
            return
            
        self.model = joblib.load(model_path)
        self.preprocessor = joblib.load(preprocessor_path)
        self.features = joblib.load(feature_path)
        print("✅ Görselleştirici başarıyla yüklendi!")
        
    def plot_feature_importance(self, feature_names=None):
        """Özellik önem sıralamasını göster"""
        try:
            if not hasattr(self.model, 'feature_importances_'):
                print("⚠️  Bu model feature_importance desteklemiyor")
                return
                
            if feature_names is None:
                feature_names = self.features
            
            importances = self.model.feature_importances_
            indices = np.argsort(importances)[::-1]
            
            plt.figure(figsize=(12, 8))
            plt.title("Gezegen Tespiti - Özellik Önem Sıralaması", fontsize=14, fontweight='bold')
            bars = plt.bar(range(len(importances)), importances[indices], color='skyblue', edgecolor='navy')
            plt.xticks(range(len(importances)), [feature_names[i] for i in indices], rotation=45, ha='right')
            plt.ylabel('Önem Derecesi')
            plt.grid(axis='y', alpha=0.3)
            
            # Değerleri çubukların üzerine yaz
            for bar, importance in zip(bars, importances[indices]):
                plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.001, 
                        f'{importance:.3f}', ha='center', va='bottom', fontsize=9)
            
            plt.tight_layout()
            plt.show()
            
            # Önem değerlerini yazdır
            print("\n📊 ÖZELLİK ÖNEM DEĞERLERİ:")
            print("-" * 40)
            for i in indices:
                print(f"🏷️  {feature_names[i]:<15}: {importances[i]:.4f}")
                
        except Exception as e:
            print(f"❌ Feature importance hatası: {e}")
    
    def plot_confusion_matrix(self, y_true, y_pred):
        """Karmaşıklık matrisi"""
        try:
            cm = confusion_matrix(y_true, y_pred)
            plt.figure(figsize=(8, 6))
            sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                        xticklabels=['False Positive', 'Confirmed Planet'],
                        yticklabels=['False Positive', 'Confirmed Planet'],
                        annot_kws={"size": 16})
            plt.title('Confusion Matrix - Model Performansı', fontsize=14, fontweight='bold')
            plt.ylabel('Gerçek Değer', fontsize=12)
            plt.xlabel('Tahmin Edilen Değer', fontsize=12)
            plt.tight_layout()
            plt.show()
            
            # İstatistikleri yazdır
            tn, fp, fn, tp = cm.ravel()
            accuracy = (tp + tn) / (tp + tn + fp + fn)
            precision = tp / (tp + fp) if (tp + fp) > 0 else 0
            recall = tp / (tp + fn) if (tp + fn) > 0 else 0
            
            print(f"\n📈 CONFUSION MATRIX İSTATİSTİKLERİ:")
            print(f"✅ Doğruluk (Accuracy): {accuracy:.2%}")
            print(f"🎯 Kesinlik (Precision): {precision:.2%}")
            print(f"🔍 Duyarlılık (Recall): {recall:.2%}")
            
        except Exception as e:
            print(f"❌ Confusion matrix hatası: {e}")
    
    def plot_roc_curve(self, y_true, y_proba):
        """ROC Eğrisi"""
        try:
            fpr, tpr, thresholds = roc_curve(y_true, y_proba)
            roc_auc = roc_auc_score(y_true, y_proba)
            
            plt.figure(figsize=(10, 8))
            plt.plot(fpr, tpr, color='darkorange', lw=3, label=f'ROC eğrisi (AUC = {roc_auc:.3f})')
            plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--', alpha=0.5)
            plt.xlim([0.0, 1.0])
            plt.ylim([0.0, 1.05])
            plt.xlabel('False Positive Rate (Sahte Pozitif Oranı)', fontsize=12)
            plt.ylabel('True Positive Rate (Gerçek Pozitif Oranı)', fontsize=12)
            plt.title('ROC Curve - Gezegen Tespiti Performansı', fontsize=14, fontweight='bold')
            plt.legend(loc="lower right", fontsize=12)
            plt.grid(alpha=0.3)
            plt.tight_layout()
            plt.show()
            
            print(f"\n📊 ROC-AUC SKORU: {roc_auc:.4f}")
            if roc_auc > 0.9:
                print("🎉 MÜKEMMEL! Model çok iyi performans gösteriyor!")
            elif roc_auc > 0.8:
                print("👍 İYİ! Model iyi performans gösteriyor.")
            else:
                print("⚠️  Model performansı iyileştirilmeli.")
                
        except Exception as e:
            print(f"❌ ROC curve hatası: {e}")
    
    def plot_correlation_heatmap(self, X, feature_names=None):
        """Özellikler arası korelasyon ısı haritası"""
        try:
            if feature_names is None:
                feature_names = self.features
                
            plt.figure(figsize=(14, 12))
            
            # DataFrame oluştur
            if isinstance(X, np.ndarray):
                X_df = pd.DataFrame(X, columns=feature_names)
            else:
                X_df = X
                
            correlation_matrix = X_df.corr()
            
            mask = np.triu(np.ones_like(correlation_matrix, dtype=bool))
            
            sns.heatmap(correlation_matrix, mask=mask, annot=True, cmap='RdBu_r', center=0,
                       fmt='.2f', linewidths=0.5, cbar_kws={"shrink": .8})
            plt.title('Özellikler Arası Korelasyon Isı Haritası', fontsize=14, fontweight='bold')
            plt.tight_layout()
            plt.show()
            
            # Yüksek korelasyonları bul
            print("\n🔗 YÜKSEK KORELASYONLAR (|r| > 0.7):")
            high_corr = []
            for i in range(len(correlation_matrix.columns)):
                for j in range(i+1, len(correlation_matrix.columns)):
                    if abs(correlation_matrix.iloc[i, j]) > 0.7:
                        high_corr.append((
                            correlation_matrix.columns[i],
                            correlation_matrix.columns[j],
                            correlation_matrix.iloc[i, j]
                        ))
            
            if high_corr:
                for feat1, feat2, corr in high_corr:
                    print(f"   {feat1} ↔ {feat2}: {corr:.3f}")
            else:
                print("   🤝 Yüksek korelasyon bulunamadı")
                
        except Exception as e:
            print(f"❌ Correlation heatmap hatası: {e}")

# Test fonksiyonu
def test_visualizations():
    """Görselleştirmeleri test et"""
    print("🧪 Görselleştirme Testi Başlıyor...")
    
    try:
        visualizer = ExoplanetVisualizer()
        print("✅ Görselleştirici başarıyla oluşturuldu!")
        
        # Test için örnek veri oluştur
        np.random.seed(42)
        n_samples = 1000
        
        # Örnek test verileri
        X_test_demo = np.random.randn(n_samples, len(visualizer.features))
        y_test_demo = np.random.randint(0, 2, n_samples)
        y_pred_demo = np.random.randint(0, 2, n_samples)
        y_proba_demo = np.random.rand(n_samples)
        
        print(f"\n📊 Demo verileri oluşturuldu: {n_samples} örnek")
        
        # Görselleştirmeleri çalıştır
        visualizer.plot_feature_importance()
        visualizer.plot_confusion_matrix(y_test_demo, y_pred_demo)
        visualizer.plot_roc_curve(y_test_demo, y_proba_demo)
        visualizer.plot_correlation_heatmap(X_test_demo)
        
        print("\n🎉 Tüm görselleştirmeler başarıyla tamamlandı!")
        
    except Exception as e:
        print(f"❌ Test hatası: {e}")

if __name__ == "__main__":
    test_visualizations()