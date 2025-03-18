defmodule MiniLand.Certificates do
  alias MiniLand.Parser.CertificateParser
  alias MiniLand.Promotions
  alias MiniLand.Repo
  alias MiniLand.Schema.Certificate

  import Ecto.Changeset

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
    attrs = Map.put(attrs, :promotion_id, promotion.id)
    attrs = Map.put(attrs, :cost, promotion.cost)
    attrs = Map.delete(attrs, :promotion_name)

    create_certificate!(attrs)
  end

  def use_certificate!(certificate_id) do
    get_certificate!(certificate_id)
    |> change(%{status: "used"})
    |> Repo.update()
  end

  def pull_certificates do
    Repo.all(Certificate)
    |> Enum.map(&CertificateParser.parse_certificate/1)
  end

  def search_certificate(phone) do
    Repo.get_by(Certificate, buyer_phone: phone)
  end

  def delete_certificate(certificate_id) do
    certificate = get_certificate!(certificate_id)

    if certificate do
      certificate
      |> change(%{status: "inactive"})
      |> Repo.update()

      :ok
    else
      {:error, "Certificate not found"}
    end
  end
end
