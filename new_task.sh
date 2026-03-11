#!/bin/bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash new_task.sh [options] --task <task1> [--task <task2> ...]

Options:
  -y               自动确认，跳过交互提示
  -h, --help       显示帮助信息

Example:
  bash new_task.sh --task projector_generator --task render_engine -y
USAGE
}

# 初始化变量
tasks=()            # 存储所有任务名的数组
auto_confirm=false  # 是否自动确认

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) 
        tasks+=("$2")       # 将任务名加入数组
        shift 2
        ;;
    -y)
        auto_confirm=true
        shift
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        echo "Unknown arg: $1" >&2
        usage
        exit 2
        ;;
  esac
done

# 检查是否至少有一个任务
if [[ ${#tasks[@]} -eq 0 ]]; then
  echo "Error: No task specified." >&2
  usage
  exit 2
fi

# 对任务名进行合法性检查（字母、数字、下划线、连字符）
for task in "${tasks[@]}"; do
  if [[ ! "$task" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Task name '$task' contains invalid characters. Allowed: letters, numbers, underscore, hyphen." >&2
    exit 2
  fi
done

# 显示将要执行的操作
echo "The following tasks will be created:"
for task in "${tasks[@]}"; do
  echo "  - ${task}_task"
done

# 如果没有 -y 选项，则询问用户确认
if [[ "$auto_confirm" != true ]]; then
  read -p "Do you want to continue? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

# 确保 tasks 目录存在
mkdir -p tasks

# 记录成功和失败的任务
success_list=()
fail_list=()

# 循环创建每个任务
for task in "${tasks[@]}"; do
  target_dir="./tasks/${task}_task"
  echo "Creating $target_dir ..."
  
  # 使用 cp -r 复制模板，并捕获错误（不中断循环）
  if cp -r ./template "$target_dir" 2>/dev/null; then
    echo "  -> Success"
    success_list+=("$task")
  else
    echo "  -> Failed (maybe template missing or target exists?)" >&2
    fail_list+=("$task")
  fi
done

# 显示最终汇总结果
echo ""
echo "========== Summary =========="
if [[ ${#success_list[@]} -gt 0 ]]; then
  echo "Successfully created:"
  for task in "${success_list[@]}"; do
    echo "  - ${task}_task"
  done
fi
if [[ ${#fail_list[@]} -gt 0 ]]; then
  echo "Failed to create:"
  for task in "${fail_list[@]}"; do
    echo "  - ${task}_task"
  done
  exit 1   # 如果有失败的任务，脚本以非零状态退出
else
  echo "All tasks created successfully."
fi