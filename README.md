# codex_kit
本地运行Codex的工具包（工具包与参考仓库独立版本）

## 文件结构
    /home/user/code/
    ├── ref_repo/                      # 原始参考仓库，只读，尽量不让 Codex 直接改
    └── codex_kit/                     # Codex 独立工作区根目录
        ├── template/                  # 任务模板，后续新任务都从这里复制
        │   ├── SPEC.md
        │   ├── README.md
        │   ├── SYNC_MANIFEST.json
        │   ├── src/
        │   │   └── __init__.py
        │   ├── tools/
        │   │   ├── run_remote.sh
        │   │   ├── standard_auto.sh
        │   │   └── prepare_manifest.sh
        │   ├── tests/
        │   ├── outputs/
        │   └── log/
        │       └── last_run/
        ├── tasks/                     # 每个具体任务一个独立目录
        │   ├── projector_task/
        │   │   ├── SPEC.md
        │   │   ├── README.md
        │   │   ├── SYNC_MANIFEST.json
        │   │   ├── src/
        │   │   │   └── __init__.py
        │   │   ├── tools/
        │   │   │   ├── run_remote.sh
        │   │   │   ├── standard_auto.sh
        │   │   │   └── prepare_manifest.sh
        │   │   ├── tests/
        │   │   ├── outputs/
        │   │   └── log/
        │   │       └── last_run/
        │   └── another_task/
        │       └── ...
        └── logs/                      # 汇总日志，可选
            ├── local_master/
            ├── local/
            └── remote/

## 环境配置

## 实例运行
