import onnx
from onnx import numpy_helper

def print_onnx_model_details(model_path):
    # モデルの読み込み
    model = onnx.load(model_path)
    graph = model.graph

    # 入力情報の取得
    print("Inputs:")
    for input_tensor in graph.input:
        input_name = input_tensor.name
        input_shape = [dim.dim_value for dim in input_tensor.type.tensor_type.shape.dim]
        print(f"  - Name: {input_name}, Shape: {input_shape}")

    # 出力情報の取得
    print("\nOutputs:")
    for output_tensor in graph.output:
        output_name = output_tensor.name
        output_shape = [dim.dim_value for dim in output_tensor.type.tensor_type.shape.dim]
        print(f"  - Name: {output_name}, Shape: {output_shape}")

    # 構成ノードの取得
    print("\nNodes:")
    for node in graph.node:
        print(f"  - Name: {node.name if node.name else '<Unnamed>'}, OpType: {node.op_type}, Inputs: {node.input}, Outputs: {node.output}")

if __name__ == "__main__":
    model_path = input("Enter the ONNX model file path: ").strip()
    try:
        print_onnx_model_details(model_path)
    except Exception as e:
        print(f"Error loading ONNX model: {e}")

