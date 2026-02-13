# Smol llama-cli helper
function smol
    if type -q llama-cli
        llama-cli -m storage/shared/Models/SmolLM3-Q4_K_M.gguf -t 2 -c 1024 --mlock --no-mmap --temp 0 --reasoning-budget 0 -st $argv
    end
end
