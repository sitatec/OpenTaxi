export const mainModal = document.getElementById("mainModal");

const closeButton = document.getElementsByClassName("close")[0];

export function showMainModal() {
  mainModal.style.display = "block";
}

export function hideMainModal () {
  mainModal.style.display = "none";
};

closeButton.onclick = hideMainModal;
