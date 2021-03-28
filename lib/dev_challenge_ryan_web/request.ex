defmodule DevChallengeRyanWeb.Request do
  @moduledoc false

  def post(_conn, _url, nil, _headers), do: {:invalid_method}
  def post(_conn, nil, _body, _headers), do: {:invalid_url}
  def post(_conn, _url, _body, headers) when not is_list(headers), do: {:invalid_headers}

  def post(conn, url, body, headers, _options \\ []) when is_list(headers) do
    options = [timeout: 600_000, recv_timeout: 600_000]

    case HTTPoison.post(url, Poison.encode!(body), process_request_header(headers), options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        process_response_body(:ok, body)

      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        process_response_body(:bad_request, body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:not_found}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        process_response_body(:bad_request, body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:internal_server_error, reason}
    end
  end

  def delete(_conn, nil, _headers), do: {:invalid_url}
  def deelte(_conn, _url, headers) when not is_list(headers), do: {:invalid_headers}

  def delete(conn, url, headers, _options \\ []) when is_list(headers) do
    options = [timeout: 600_000, recv_timeout: 600_000]

    case HTTPoison.delete(url, process_request_header(headers), options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        process_response_body(:ok, body)

      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        process_response_body(:bad_request, body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:not_found}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        process_response_body(:bad_request, body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:internal_server_error, reason}
    end
  end

  def get(_conn, nil, _headers), do: {:invalid_url}
  def get(_conn, _url, headers) when not is_list(headers), do: {:invalid_headers}

  def get(conn, url, headers, options \\ []) when is_list(headers) do
    case HTTPoison.get(url, process_request_header(headers), options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        process_response_body(:ok, body)

      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        process_response_body(:bad_request, body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:not_found}

      {:ok, %HTTPoison.Response{status_code: _code, body: body}} ->
        process_response_body(:bad_request, body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:internal_server_error, reason}
    end
  end

  def process_response_body(status, body) do
    body =
      body
      |> Poison.decode!()
      |> body_checker()

    {status, body}
  rescue
    _ ->
      {:internal_server_error, "Invalid response"}
  end

  def body_checker(decoded_body) when is_list(decoded_body), do: decoded_body
  def body_checker(decoded_body) when is_map(decoded_body), do: decoded_body
  def body_check(%{"msg" => "success"} = decoded_body), do: decoded_body

  def body_checker(decoded_body) do
    [decoded_body]
  end

  defp process_request_header(headers) do
    headers ++ ["Content-Type": "application/json"]
  end

  def process_request_url(url, key) do
    service_url =
      :dev_challenge_ryan
      |> Application.get_env(DevChallengeRyanWeb.UtilityContext)
      |> Keyword.get(key)

    HTTPoison.process_request_url(service_url <> url)
  end
end
