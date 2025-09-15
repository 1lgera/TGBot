import yaml
import sys
sys.path.append("../..")

config = yaml.safe_load(open("../../config.yml","r", encoding="utf8"))

if __name__ == "__main__":
    print(config)