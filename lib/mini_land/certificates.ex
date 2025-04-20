defmodule MiniLand.Certificates do
  alias MiniLand.Promotions
  alias MiniLand.Render.CertificateJson
  alias MiniLand.Repo
  alias MiniLand.Schema.Certificate

  import Ecto.Changeset
  import Ecto.Query

  def get_certificate!(certificate_id) do
    Repo.get!(Certificate, certificate_id)
  end

  def create_certificate!(attrs) do
    %Certificate{}
    |> change(attrs)
    |> Repo.insert!()
  end

  def create_new_certificate(attrs) do
    promotion = Promotions.get_promotion_by_name(attrs.promotion_name)

    if promotion do
      certificate =
        create_certificate!(%{
          buyer_full_name: attrs.buyer_full_name,
          buyer_phone: attrs.buyer_phone,
          receiver_full_name: attrs.receiver_full_name,
          receiver_phone: attrs.receiver_phone,
          cost: promotion.cost,
          promotion_id: promotion.id
        })

      {:ok, CertificateJson.render_certificate(certificate)}
    else
      {:error, :promotion_not_found}
    end
  end

  def use_certificate!(certificate_id) do
    get_certificate!(certificate_id)
    |> change(%{status: "used"})
    |> Repo.update()
  end

  def pull_certificates do
    Repo.all(Certificate)
    |> Enum.filter(&(&1.status == "pending"))
    |> Enum.map(&CertificateJson.render_certificate/1)
  end

  def search_certificate(phone) do
    certificates_by_receiver_phone =
      Certificate
      |> where([c], c.receiver_phone == ^phone)
      |> Repo.all()
      |> Enum.map(&CertificateJson.render_certificate/1)

    certificates_by_buyer_phone =
      Certificate
      |> where([c], c.buyer_phone == ^phone)
      |> Repo.all()
      |> Enum.map(&CertificateJson.render_certificate/1)

    {:ok, %{receiver: certificates_by_receiver_phone, buyer: certificates_by_buyer_phone}}
  end

  def delete_certificate(certificate_id) do
    certificate = get_certificate!(certificate_id)

    if certificate do
      certificate
      |> change(%{status: "inactive"})
      |> Repo.update()

      {:ok, :deleted}
    else
      {:error, :not_found}
    end
  end
end
