package tz.mapato.mapato

import java.util.regex.Pattern

/// Helpers to decide whether a notification/SMS originates from a real
/// Tanzanian mobile-money source. We filter on the *sender*, not the text
/// content, so a user typing money-like words in a chat is never treated as a
/// transaction.
object MnoFilters {
    // Alphanumeric sender identifiers used by the operators.
    private val SENDER_KEYWORDS = listOf(
        "m-pesa", "mpesa", "vodacom",
        "tigo", "yas", "mixx", "mix by yas",
        "airtel", "airtelmoney",
        "halo", "halopesa",
        "azam", "azampesa",
        "mobile money", "mobility",
    )

    private val SHORTCODE = Pattern.compile("^\\d{3,6}$")

    /** True when [sender] looks like an operator shortcode or name. */
    fun isMnoSender(sender: String?): Boolean {
        if (sender.isNullOrBlank()) return false
        val s = sender.lowercase().trim()
        if (SHORTCODE.matcher(s).matches()) return true
        return SENDER_KEYWORDS.any { s.contains(it) }
    }

    /** True when [pkg] is an official operator app we trust outright. */
    fun isMnoPackage(pkg: String?): Boolean = pkg != null && MNO_PACKAGES.contains(pkg)

    // Mirrors the default capture list in MapatoNotificationService.
    private val MNO_PACKAGES = setOf(
        "com.vodacom.mpesa",
        "tz.tigo.mfsapp",
        "com.tigo.pesa",
        "com.airtel.money",
        "com.halopesa.eu",
        "tz.co.halo.halopesa",
        "com.azampesa",
    )
}
