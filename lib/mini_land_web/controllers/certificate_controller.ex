defmodule MiniLandWeb.CertificateController do
  alias MiniLand.Certificates
  alias MiniLand.Orders

  use MiniLandWeb, :controller

  defmodule CreateCertificateContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:buyer_full_name) => string(:filled?),
        required(:buyer_phone) => string(:filled?),
        required(:receiver_full_name) => string(:filled?),
        required(:receiver_phone) => string(:filled?),
        required(:promotion_name) => string(:filled?)
      }
    end
  end

  def create_certificate(conn, unsafe_params) do
    with {:ok, params} <- CreateCertificateContract.conform(unsafe_params) do
      case Certificates.create_new_certificate(params) do
        {:ok, certificate} ->
          render_response(conn, {:ok, :created, %{certificate_id: certificate.id}})

        {:error, :promotion_not_found} ->
          render_response(conn, {:error, :not_found, "Promotion not found"})
      end
    end
  end

  defmodule UseCertificateContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:certificate_id) => integer(:filled?),
        required(:attrs) => %{
          required(:order_type) => string(:filled?),
          required(:promotion_name) => string(:filled?),
          required(:child_full_name) => string(:filled?),
          required(:child_age) => integer(),
          required(:parent_full_name) => string(:filled?),
          required(:parent_phone) => string(:filled?)
        }
      }
    end
  end

  def use_certificate(conn, unsafe_params) do
    with {:ok, params} <- UseCertificateContract.conform(unsafe_params) do
      user_id = conn.assigns.user_id
      attrs = Map.put(params.attrs, :user_id, user_id)

      {:ok, _certificate} = Certificates.use_certificate!(params.certificate_id)
      order = Orders.create_new_order(attrs)
      render_response(conn, {:ok, %{order_id: order.id}})
    end
  end

  def get_certificates(conn, _params) do
    certificates = Certificates.pull_certificates()
    render_response(conn, {:ok, certificates})
  end

  def search_certificate(conn, %{phone: phone}) do
    certificate = Certificates.search_certificate(phone)
    render_response(conn, {:ok, certificate})
  end

  def delete_certificate(conn, _params) do
    certificate_id = conn.params["id"]

    case Certificates.delete_certificate(certificate_id) do
      :ok ->
        render_response(conn, {:ok, %{message: "Certificate disabled"}})

      {:error, error} ->
        render_response(conn, {:error, error})
    end
  end

  defp render_response(conn, response) do
    case response do
      {:ok, data} ->
        json(conn, {:ok, data})

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{msg: "Not found"})

      {:error, error} ->
        conn
        |> put_status(500)
        |> json(%{msg: "Some unknown internal server error", error: error})
    end
  end
end
