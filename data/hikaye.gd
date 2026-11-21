# Hikaye yazilari (birlesik surum, 12. tur, kullanici istegi: "hikayeyi 6-8 kisa yazi sahnesiyle yay"): oyun boyunca gun sonunda,
# kosulu ilk saglandiginda bir kez gosterilen kisa kartlar. Sira = gosterim sirasi. Kosullar systems/events/hikaye_system.gd'de
# (f_kosul); metinler buradadir, ceviriler sozluklerde. tur: kartin gorunumu (mektup = krem + kirmizi serit, baba = sicak
# parsomen + altin, resmi = soguk gri + muhur).
extends RefCounted

const VALUE = [
	{"id": "icra_zarf", "tur": "resmi", "baslik": "İCRA DAİRESİ", "satir": ["Kapının altından bir zarf geçmiş.", "Taksit bildirimi: kazancının %18'i", "her hafta kasadan tahsil edilecek.", "İlk ziyaret 13. gün sabahı.", "Kasa boşsa ihtar. İki ihtar, mühür."]},
	{"id": "rakip_tanisma", "tur": "mektup", "baslik": "KARŞIDAKİ DÜKKÂN", "satir": ["Karşıya yeni bir dükkân açılmış.", "Sahibi Kâmil Usta, babamın eski çırağı.", "Babam kendi ocağını kurunca küsmüş.", "Şimdi bahse tutuşmak istiyor."]},
	{"id": "ilk_sube", "tur": "baba", "baslik": "BABA'NIN SÖZÜ", "satir": ["İlk şubenin anahtarı elimde.", "Babamın sözü geldi aklıma:", "\"Bir tezgâh mahalleyi doyurur,", "iyi bir ad şehirleri.\""]},
	{"id": "icra_memur", "tur": "resmi", "baslik": "HAMDİ BEY", "satir": ["Memur Hamdi Bey kapıda durakladı:", "\"Babanı tanırdım. Borcu olan bir adam", "yine de kimseyi aç göndermezdi.\"", "\"Kural kural. Ama ben senin yanındayım.\""]},
	{"id": "rakip_kapandi", "tur": "mektup", "baslik": "KÂMİL USTA", "satir": ["Karşıdaki kepenk bu sabah hiç kalkmadı.", "Kâmil Usta pes etmiş; kapıya not asmış:", "\"Baban haklıydı, usta.\"", "Karşı dükkân artık sessiz."]},
	{"id": "yari_yol", "tur": "baba", "baslik": "YARI YOL", "satir": ["Borcun yarısı gitti.", "Babam görse bıyık altından gülerdi.", "Ama memur her hafta kapıda;", "yarı yol, yol sayılmaz."]},
	{"id": "demirkent_mektup", "tur": "resmi", "baslik": "DEMİRKENT'TEN MEKTUP", "satir": ["Zarfta devlet mührü: DEMİRKENT.", "\"Şehrimiz sizi bekliyor. Her sabah", "bir ferman yayınlanır; uymayan", "dükkân kapanır.\" Fiyat: 2,5 milyon."]},
	{"id": "demirkent_ilk", "tur": "resmi", "baslik": "DEMİRKENT'İN İLK GÜNÜ", "satir": ["Burada kimse gülmüyor.", "Kapıya ferman listesi asılmış.", "Ev kirası, yemek, ısınma, ilaç…", "Dükkân kazanırsa sofra kurulur."]},
]

# Kapanis hikayesinin Demirkent'e bagli sahnesi (story_draw.f_epiStart): oyuncunun Demirkent'te yaptigi seceneklere gore satirlar
const EPI_DEMIRKENT = {
	"direnis": ["Demirkent'te bir kez kapıma mühür vurdular.", "Kepengi yine kaldırdım; o şehirde ısrar şart."],
	"sifa": ["Demirkent'te de aç gelen geri dönmedi.", "Ferman ne derse desin, Baba'nın sözü eskidir."],
	"uyum": ["Demirkent'te fermana uydum.", "Her sabah kuralı okudum; kepenk açık kaldı."],
	"sofra_tam": "Sofra eksiksiz.",
	"sofra_eksik": "Ama sofrada boş sandalyeler kaldı.",
}
