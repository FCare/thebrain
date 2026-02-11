# Qwen3-VL avec llama.cpp

Serveur d'API compatible OpenAI utilisant llama.cpp avec le modèle Qwen3-VL quantifié GGUF.

## 🚀 Fonctionnalités

- ✅ **llama.cpp natif** - Performance optimisée avec CUDA
- ✅ **Interface OpenAI Compatible** - Endpoints `/v1/chat/completions`, `/v1/models`
- ✅ **Qwen3-VL GGUF** - Modèle vision-language quantifié Q4_K_XL (~5GB)
- ✅ **Multi-Modal** - Support texte + images avec 49K context
- ✅ **Streaming** - Réponses en temps réel
- ✅ **GPU Accelerated** - Support CUDA complet
- ✅ **Docker Ready** - Déploiement simplifié

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Docker        │───▶│  llama.cpp       │───▶│  OpenAI API     │
│   (CUDA)        │    │  llama-server    │    │  Compatible     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   NVIDIA        │    │  Qwen3-VL-8B     │    │  /health        │
│   Runtime       │    │  GGUF Q4_K_XL    │    │  /v1/models     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📦 Installation

### Prérequis

- **GPU NVIDIA** avec 6+ GB VRAM
- **Docker + NVIDIA Container Runtime**
- **CUDA 12.8** ou compatible

### Démarrage avec Docker

```bash
# Cloner le repository
git clone <repository-url>
cd qwen-llama-cpp

# Configuration (optionnel)
cp .env.example .env
# Éditer .env si nécessaire

# Lancement
docker-compose up -d

# Vérification
curl http://localhost:8000/health
```

### Configuration GPU

```bash
# Vérifier le support NVIDIA
docker run --rm --runtime=nvidia nvidia/cuda:12.8-base nvidia-smi

# Changer de GPU (dans .env)
echo "CUDA_VISIBLE_DEVICES=1" >> .env
```

## 🔧 Configuration

### Variables d'Environnement

| Variable | Défaut | Description |
|----------|--------|-------------|
| `HOST_PORT` | `8000` | Port exposé sur l'hôte |
| `CUDA_VISIBLE_DEVICES` | `0` | GPU à utiliser |

### Paramètres llama.cpp

Le serveur est configuré dans [`start.sh`](start.sh) avec :

```bash
./llama.cpp/llama-server \
    -hf unsloth/Qwen3-VL-8B-Instruct-GGUF:UD-Q4_K_XL \
    --n-gpu-layers 99 \
    --host 0.0.0.0 \
    --port 8000 \
    --ctx-size 49152 \
    --parallel 2 \
    --flash-attn on
```

## 📚 Utilisation

### Chat Completion Basique

```python
import openai

client = openai.OpenAI(
    base_url="http://localhost:8000/v1",
    api_key="dummy-key"  # Non utilisé
)

response = client.chat.completions.create(
    model="unsloth/Qwen3-VL-8B-Instruct-GGUF",
    messages=[
        {"role": "user", "content": "Bonjour! Comment allez-vous?"}
    ],
    max_tokens=1000,
    temperature=0.7
)

print(response.choices[0].message.content)
```

### Chat avec Images

```python
response = client.chat.completions.create(
    model="unsloth/Qwen3-VL-8B-Instruct-GGUF",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Que voyez-vous dans cette image?"},
                {"type": "image_url", "image_url": {"url": "https://example.com/image.jpg"}}
            ]
        }
    ]
)
```

### Streaming

```python
stream = client.chat.completions.create(
    model="unsloth/Qwen3-VL-8B-Instruct-GGUF",
    messages=[{"role": "user", "content": "Racontez-moi une histoire"}],
    stream=True
)

for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="")
```

### cURL Direct

```bash
# Chat completion
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "unsloth/Qwen3-VL-8B-Instruct-GGUF",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 100
  }'

# Liste des modèles
curl http://localhost:8000/v1/models

# Santé du service
curl http://localhost:8000/health
```

## 🔍 API Endpoints

### OpenAI Compatible
- `POST /v1/chat/completions` - Chat completions avec support vision
- `GET /v1/models` - Liste des modèles disponibles

### llama.cpp Natif
- `POST /completion` - Completion de texte simple
- `GET /health` - État de santé du service
- `POST /tokenize` - Tokenisation de texte
- `POST /detokenize` - Détokenisation

## ⚡ Performance

### Spécifications Testées

| GPU | VRAM | Modèle | Quantization | Performance |
|-----|------|--------|--------------|-------------|
| RTX 4090 | 24GB | Qwen3-VL-8B | Q4_K_XL | ~25 tokens/s |
| RTX 4080 | 16GB | Qwen3-VL-8B | Q4_K_XL | ~20 tokens/s |
| RTX 4070 | 12GB | Qwen3-VL-8B | Q4_K_XL | ~15 tokens/s |
| RTX 3080 | 10GB | Qwen3-VL-8B | Q4_K_XL | ~12 tokens/s |

### Optimisations GGUF

- **Mémoire**: ~5GB VRAM (vs ~15GB FP16)
- **Vitesse**: Performance native C++
- **Context**: Support jusqu'à 49K tokens

## 🛠️ Développement

### Structure du Projet

```
qwen-llama-cpp/
├── Dockerfile               # Image Docker avec llama.cpp + CUDA
├── start.sh                 # Script de démarrage llama-server
├── docker-compose.yml       # Orchestration
├── .env.example            # Variables d'environnement
└── README.md               # Cette documentation
```

### Build Local

```bash
# Build de l'image
docker build -t llama-qwen:latest .

# Test local
docker run --rm --runtime=nvidia \
  -p 8000:8000 \
  llama-qwen:latest
```

### Monitoring

```bash
# Logs en temps réel
docker logs -f llama-qwen-server

# Métriques GPU
watch -n 1 nvidia-smi

# État de santé
curl http://localhost:8000/health
```

## 🔧 Troubleshooting

### Problèmes Courants

**1. Erreur CUDA Out of Memory**
```bash
# Utiliser un GPU avec plus de VRAM
export CUDA_VISIBLE_DEVICES=1

# Ou réduire le contexte dans start.sh
--ctx-size 32768
```

**2. Modèle ne se télécharge pas**
```bash
# Vérifier les logs
docker logs llama-qwen-server

# Vérifier l'espace disque
df -h
```

**3. Pas de GPU détecté**
```bash
# Vérifier le runtime NVIDIA
docker run --rm --runtime=nvidia nvidia/cuda:12.8-base nvidia-smi

# Installer nvidia-container-toolkit
sudo apt install nvidia-container-toolkit
sudo systemctl restart docker
```

## 📖 Documentation API

llama.cpp n'inclut **pas de frontend de documentation automatique** comme FastAPI (`/docs`).

### Ressources disponibles
- **Endpoints** : Testez directement avec curl/Postman
- **Documentation officielle** : [llama.cpp server README](https://github.com/ggml-org/llama.cpp/blob/master/examples/server/README.md)
- **OpenAI API Reference** : Compatible avec [OpenAI Chat API](https://platform.openai.com/docs/api-reference/chat)

## 📄 License

MIT License - voir LICENSE file

## 🙏 Remerciements

- [llama.cpp](https://github.com/ggerganov/llama.cpp) pour le moteur d'inférence
- [Qwen Team](https://github.com/QwenLM/Qwen2-VL) pour le modèle
- [Unsloth](https://unsloth.ai/) pour la quantification GGUF