class Result<T>{
  bool get success => this._success;
  String get errorMessage => this._errorMessage;
  T get data => this._data;

  bool _success;
  String _errorMessage;
  T _data;

  Result.success(this._data){
    this._success = true;
    this._errorMessage = null;
  }

  Result.error(this._errorMessage,{T result}){
    this._success = false;
    this._data = result;
  }
}