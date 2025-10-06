# exoplanet_tabular_pipeline.py
# GÜNCELLENDİ: Daha fazla veri, daha iyi feature eşleme, CANDIDATE'ler dahil

import os
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, StratifiedKFold, cross_val_score, cross_validate
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
import joblib
from sklearn.metrics import classification_report, roc_auc_score, precision_recall_fscore_support, confusion_matrix
import warnings
warnings.filterwarnings("ignore")

# Optional xgboost import (if available)
try:
    from xgboost import XGBClassifier
    has_xgb = True
except Exception:
    has_xgb = False

# ---------------------------
# 1) Paths - değiştir kendine göre
# ---------------------------
koi_path = "cumulative_2025.10.04_02.11.48.csv"   # KOI (Kepler)
toi_path = "TOI_2025.10.04_02.11.58.csv"    # TOI (TESS)
k2_path  = "k2pandc_2025.10.04_02.12.05.csv"   # K2

# ---------------------------
# 2) Helper: otomatik column bulucu
# ---------------------------
def find_first_column(df, candidates):
    for c in candidates:
        if c in df.columns:
            return c
    return None

# Map concept -> olası kolon isimleri (GENİŞLETİLDİ)
FEATURE_NAME_MAP = {
    "period": ["koi_period", "pl_orbper", "pl_orbpererr1", "orbital_period", "P", "pl_period", "pl_orbper"],
    "duration": ["koi_duration", "pl_trandur", "pl_trandurh", "transit_duration", "duration", "pl_trandur"],
    "depth": ["koi_depth", "pl_trandep", "tran_depth", "depth", "pl_trandep", "pl_trandeperr1", "pl_trandep"],
    "ror": ["koi_ror", "pl_ratror", "pl_ratrorerr1", "radius_ratio", "ror", "pl_ratror"],
    "prad": ["koi_prad", "pl_rade", "pl_radj", "pl_radeerr1", "planet_radius", "pl_rads", "pl_radius"],
    "srad": ["koi_srad", "st_rad", "st_radius", "st_raderr1", "star_radius", "st_rad"],
    "srho": ["koi_srho", "st_density", "st_rho", "st_rhoerr1", "st_dens"],
    "kepmag": ["koi_kepmag", "kepmag", "st_kepmag", "mag", "kepler_magnitude", "st_tmag", "st_kmag"],
    "model_snr": ["koi_model_snr", "pl_model_snr", "model_snr", "snr", "pl_snr"],
    "insol": ["koi_insol", "pl_insol", "insol", "insolation", "pl_insol", "pl_insolerr1"],
    "teq": ["koi_teq", "pl_eqt", "teq", "equilibrium_temperature", "pl_eqt", "pl_eqterr1"],
}

# Label candidates per dataset - GENİŞLETİLDİ
LABEL_CANDIDATES = [
    "koi_disposition", "Disposition Using Kepler Data", "disposition",
    "TFOPWG Disposition", "toi_disposition", "TFOPWG_Disposition", "tfopwg_disp",
    "archive_disposition", "archived_disposition", "koi_pdisposition",
    "Exoplanet Archive Disposition", "disp", "status", "class", "type"
]

# Strings to map to binary - GENİŞLETİLDİ (CANDIDATE'ler dahil)
POSITIVE_LABEL_KEYWORDS = [
    "CONFIRMED", "CONFIRMED PLANET", "CONFIRMED_PLANET", "CONFIRMED_PLANETS", 
    "KP", "KNOWN PLANET", "KP (KNOWN PLANET)", "KNOWN_PLANET", "CANDIDATE",
    "PC", "PLANET CANDIDATE", "FALSE POSITIVE CANDIDATE", "CP", "PC (PLANET CANDIDATE)", "PC CANDIDATE"
]
NEGATIVE_LABEL_KEYWORDS = [
    "FALSE POSITIVE", "FALSE_POSITIVE", "FP", "FALSE POS", "NOT A PLANET",
    "NOT PLANET", "FALSE", "NON PLANET", "NON-PLANET", "FA", "FALSE ALARM"
]

# ---------------------------
# 3) Load function
# ---------------------------
def load_table(path):
    print(f"Loading {path} ...")
    
    try:
        # Yorum satırlarını atlayarak oku
        df = pd.read_csv(path, comment='#', low_memory=False)
        print(f"  ✅ Successfully loaded. Shape: {df.shape}")
        
    except Exception as e:
        print(f"  ❌ Error with comment skipping: {e}")
        print("  🔧 Trying manual parsing...")
        
        # Manuel parsing
        lines = []
        with open(path, 'r', encoding='utf-8') as f:
            for line in f:
                if not line.startswith('#'):
                    lines.append(line)
        
        # Geçici dosya oluştur
        temp_path = "temp_data.csv"
        with open(temp_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        
        df = pd.read_csv(temp_path, low_memory=False)
        os.remove(temp_path)
        print(f"  ✅ Manually loaded. Shape: {df.shape}")
    
    return df

# ---------------------------
# 4) Data Quality Check - YENİ EKLENDİ
# ---------------------------
def check_data_quality(X, y, dataset_name):
    """Veri kalitesini kontrol et"""
    print(f"\n📊 {dataset_name} VERİ KALİTESİ:")
    print(f"   📈 Toplam kayıt: {len(X):,}")
    print(f"   🎯 Özellik sayısı: {X.shape[1]}")
    print(f"   🪐 Gezegen oranı: {y.mean():.1%}")
    
    # Eksik veri analizi
    missing_data = X.isnull().sum()
    high_missing = missing_data[missing_data > len(X) * 0.5]  # %50'den fazla eksik
    print(f"   ❌ Yüksek eksiklikli sütun: {len(high_missing)}")
    
    # Mevcut özellikleri göster
    available_features = [col for col in X.columns if not X[col].isnull().all()]
    print(f"   ✅ Kullanılabilir özellik: {len(available_features)}")
    
    return len(high_missing)

# ---------------------------
# 5) Extract features from a single dataframe
# ---------------------------
def extract_features_and_label(df, drop_candidates=False):  # FALSE YAPILDI
    # find label column
    label_col = find_first_column(df, LABEL_CANDIDATES)
    if label_col is None:
        print("Available columns in this dataset:")
        for i, col in enumerate(df.columns.tolist()):
            print(f"  {i+1:2d}. {col}")
        
        # Otomatik olarak disposition veya status içeren sütunları ara
        possible_label_cols = [col for col in df.columns if 'disposition' in col.lower() or 'status' in col.lower() or 'type' in col.lower() or 'disp' in col.lower()]
        if possible_label_cols:
            print(f"\nPossible label columns found: {possible_label_cols}")
            label_col = possible_label_cols[0]
            print(f"Using automatically detected label column: {label_col}")
        else:
            raise ValueError("No label column found among candidates.")

    print(" -> Using label column:", label_col)
    
    # Label sütunundaki benzersiz değerleri göster
    unique_labels = df[label_col].astype(str).unique()
    print(f" -> Unique values in label column: {list(unique_labels)}")

    # Map raw label strings to uniform values
    labels_raw = df[label_col].astype(str).str.upper().str.strip()

    # Build binary label: CONFIRMED/CANDIDATE -> 1, FALSE POSITIVE -> 0
    positive_mask = labels_raw.isin(POSITIVE_LABEL_KEYWORDS)
    negative_mask = labels_raw.isin(NEGATIVE_LABEL_KEYWORDS)
    
    # Eşleşmeyen değerleri otomatik sınıflandır
    for val in labels_raw.unique():
        if val not in POSITIVE_LABEL_KEYWORDS and val not in NEGATIVE_LABEL_KEYWORDS:
            if any(keyword in val for keyword in ['CONFIRM', 'CANDIDATE', 'PLANET', 'CP', 'PC', 'KP']):
                print(f"    -> Auto-mapping '{val}' to POSITIVE")
                positive_mask = positive_mask | (labels_raw == val)
            elif any(keyword in val for keyword in ['FALSE', 'FP', 'NOT', 'NON', 'FA']):
                print(f"    -> Auto-mapping '{val}' to NEGATIVE")
                negative_mask = negative_mask | (labels_raw == val)

    y = pd.Series(index=df.index, dtype="float64")
    y[positive_mask] = 1.0
    y[negative_mask] = 0.0

    if drop_candidates:
        keep_mask = positive_mask | negative_mask
        print(f" -> Keeping {keep_mask.sum()} labeled rows (dropping unclassified)")
    else:
        # Tüm kayıtları tut (CANDIDATE'ler dahil)
        keep_mask = ~y.isna()
        print(f" -> Keeping all {keep_mask.sum()} rows (CANDIDATEs included)")

    # Now features: loop FEATURE_NAME_MAP and pick first existing column
    features = {}
    available_features = []
    missing_features = []
    
    for feat_key, candidates in FEATURE_NAME_MAP.items():
        col = find_first_column(df, candidates)
        if col is not None:
            features[feat_key] = df[col]
            available_features.append(feat_key)
        else:
            # mark missing by NaN series
            features[feat_key] = pd.Series(index=df.index, dtype=float)
            missing_features.append(feat_key)

    X = pd.DataFrame(features)
    print(f" -> Available features: {available_features}")
    if missing_features:
        print(f" -> Missing features: {missing_features}")

    # Subset to rows with labels available
    X = X.loc[keep_mask].reset_index(drop=True)
    y = y.loc[keep_mask].reset_index(drop=True).astype(int)

    print(" -> After filtering labeled rows:", X.shape, "labels:", y.value_counts().to_dict())
    return X, y

# ---------------------------
# 6) Load all three tables and combine (stack)
# ---------------------------
def build_combined_dataset(koi_path=None, toi_path=None, k2_path=None, drop_candidates=False):  # FALSE YAPILDI
    data_frames = []
    labels = []

    for p in [koi_path, toi_path, k2_path]:
        if p is None:
            continue
        if not os.path.exists(p):
            print("  WARNING: file not found:", p)
            continue
        print(f"\n{'='*50}")
        print(f"Processing: {p}")
        print(f"{'='*50}")
        df = load_table(p)
        X, y = extract_features_and_label(df, drop_candidates=drop_candidates)
        data_frames.append(X)
        labels.append(y)

    if not data_frames:
        raise ValueError("No valid datasets loaded. Check paths.")

    # Concatenate
    X_all = pd.concat(data_frames, axis=0).reset_index(drop=True)
    y_all = pd.concat(labels, axis=0).reset_index(drop=True)

    # VERİ KALİTESİ KONTROLÜ - YENİ EKLENDİ
    print("\n" + "="*60)
    print("VERİ KALİTESİ RAPORU:")
    print("="*60)
    
    total_records = 0
    for i, (X, y) in enumerate(zip(data_frames, labels)):
        dataset_name = ["KOI", "TOI", "K2"][i]
        high_missing = check_data_quality(X, y, dataset_name)
        total_records += len(X)

    print(f"\n📈 TOPLAM: {total_records:,} kayıt")
    print("🎯 FINAL DATASET:")
    print("Combined dataset shape:", X_all.shape)
    print("Labels distribution:", y_all.value_counts().to_dict())
    print("Label ratio (Planet/Non-Planet):", f"{y_all.mean():.1%}")
    
    return X_all, y_all


# ---------------------------
# 7) Preprocessing and train/test split
# ---------------------------
from sklearn.pipeline import make_pipeline

def preprocess_and_split(X, y, test_size=0.2, random_state=42):
    print("\n🔧 PREPROCESSING AND SPLITTING...")
    
    # basic cleaning: drop columns with >80% missing
    missing_frac = X.isnull().mean()
    drop_cols = missing_frac[missing_frac > 0.8].index.tolist()
    if drop_cols:
        print("Dropping columns with >80% missing:", drop_cols)
        X = X.drop(columns=drop_cols)
    else:
        print("No columns with >80% missing - keeping all features")

    # train-test split stratified
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=random_state, stratify=y
    )
    print("✅ Split shapes: X_train", X_train.shape, "X_test", X_test.shape)
    print("📊 Train labels:", y_train.value_counts().to_dict())
    print("📊 Test labels:", y_test.value_counts().to_dict())
    return X_train, X_test, y_train, y_test

# ---------------------------
# 8) Build pipeline and evaluate multiple models
# ---------------------------
from sklearn.metrics import roc_auc_score, accuracy_score, precision_score, recall_score, f1_score

def evaluate_models(X_train, y_train, X_test, y_test, use_xgb=has_xgb):
    print("\n🤖 TRAINING MODELS...")
    
    # Preprocessing pipeline: impute median + scale
    preproc = Pipeline([
        ("imputer", SimpleImputer(strategy="median")),
        ("scaler", StandardScaler())
    ])

    X_train_pp = pd.DataFrame(preproc.fit_transform(X_train), columns=X_train.columns, index=X_train.index)
    X_test_pp = pd.DataFrame(preproc.transform(X_test), columns=X_test.columns, index=X_test.index)

    models = {
        "LogisticRegression": LogisticRegression(max_iter=1000, solver='liblinear', random_state=42),
        "RandomForest": RandomForestClassifier(n_estimators=200, random_state=42, n_jobs=-1)
    }
    if use_xgb:
        models["XGBoost"] = XGBClassifier(use_label_encoder=False, eval_metric='logloss', random_state=42, n_jobs=4)

    results = {}
    for name, model in models.items():
        print(f"\n🔍 Training & evaluating: {name}")
        model.fit(X_train_pp, y_train)
        y_pred = model.predict(X_test_pp)
        y_proba = model.predict_proba(X_test_pp)[:,1] if hasattr(model, "predict_proba") else model.decision_function(X_test_pp)
        
        # Calculate metrics
        metrics = {
            "accuracy": accuracy_score(y_test, y_pred),
            "precision": precision_score(y_test, y_pred, zero_division=0),
            "recall": recall_score(y_test, y_pred, zero_division=0),
            "f1": f1_score(y_test, y_pred, zero_division=0),
            "roc_auc": roc_auc_score(y_test, y_proba)
        }
        
        print("  📈 Metrics:", {k: f"{v:.3f}" for k, v in metrics.items()})
        print("  📊 Classification Report:")
        print(classification_report(y_test, y_pred, zero_division=0))
        
        # Confusion matrix
        cm = confusion_matrix(y_test, y_pred)
        print(f"  🎯 Confusion Matrix:\n{cm}")
        
        results[name] = {"model": model, "metrics": metrics}
    
    return results, preproc

# ---------------------------
# 9) Choose best model by roc_auc and save it
# ---------------------------
def select_and_save_best(results, preproc, X_columns, out_dir="models", metric="roc_auc"):
    print(f"\n💾 SELECTING AND SAVING BEST MODEL...")
    os.makedirs(out_dir, exist_ok=True)
    
    # select best
    best_name = None
    best_score = -np.inf
    for name, info in results.items():
        s = info["metrics"].get(metric, -np.inf)
        if s is None:
            s = -np.inf
        if s > best_score:
            best_score = s
            best_name = name
    
    print("🎯 BEST MODEL:", best_name, "score:", f"{best_score:.3f}")
    best_model = results[best_name]["model"]

    # Save pipeline components: preproc, model, feature list
    joblib.dump(best_model, os.path.join(out_dir, "best_model.pkl"))
    joblib.dump(preproc, os.path.join(out_dir, "preprocessor.pkl"))
    joblib.dump(list(X_columns), os.path.join(out_dir, "feature_list.pkl"))
    
    print("✅ Saved to models/ directory:")
    print("   - best_model.pkl")
    print("   - preprocessor.pkl") 
    print("   - feature_list.pkl")
    
    # Show feature importance if available
    if hasattr(best_model, "feature_importances_"):
        print("\n🎯 FEATURE IMPORTANCE (Top 10):")
        feature_importance = pd.DataFrame({
            'feature': X_columns,
            'importance': best_model.feature_importances_
        }).sort_values('importance', ascending=False)
        
        for i, row in feature_importance.head(10).iterrows():
            print(f"   {row['feature']}: {row['importance']:.3f}")
    
    return best_name, best_score

# ---------------------------
# 10) Workflow main
# ---------------------------
if __name__ == "__main__":
    try:
        print("🚀 EXOPLANET DETECTION PIPELINE - GÜNCELLENMİŞ")
        print("=" * 60)
        
        # 1-2) build dataset - CANDIDATE'ler DAHIL
        X_all, y_all = build_combined_dataset(
            koi_path=koi_path, 
            toi_path=toi_path, 
            k2_path=k2_path, 
            drop_candidates=False  # CANDIDATE'ler DAHIL
        )

        # 3) split + preprocessing
        X_train, X_test, y_train, y_test = preprocess_and_split(X_all, y_all, test_size=0.2)

        # 4) train & evaluate
        results, preproc = evaluate_models(X_train, y_train, X_test, y_test)

        # 5) select & save best
        best_name, best_score = select_and_save_best(results, preproc, X_train.columns, out_dir="models")

        print("\n🎉 PIPELINE COMPLETED SUCCESSFULLY!")
        print("=" * 50)
        print(f"📊 FINAL RESULTS:")
        print(f"   • Total Records: {len(X_all):,}")
        print(f"   • Best Model: {best_name}")
        print(f"   • ROC-AUC Score: {best_score:.3f}")
        print(f"   • Features Used: {X_train.shape[1]}")
        print(f"   • Planet/Non-Planet Ratio: {y_all.mean():.1%}")
        print("\n✅ Model ready for mobile app integration!")
    
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()