/*
 * 2026 BFA-HavenCore
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <OpenSSLCrypto.h>
#include <openssl/crypto.h>
#include <openssl/provider.h>

// OpenSSL 3.x handles threading internally - no application-side locking needed.
// We use this setup/cleanup to load the legacy provider (required for RC4 cipher
// used in the old WoW auth protocol) and the default provider.

static OSSL_PROVIDER* legacyProvider = nullptr;
static OSSL_PROVIDER* defaultProvider = nullptr;

void OpenSSLCrypto::threadsSetup()
{
    // Load the default provider (AES, SHA, etc.)
    defaultProvider = OSSL_PROVIDER_load(nullptr, "default");

    // Load the legacy provider (RC4, MD5, etc. - needed for old WoW auth)
    legacyProvider = OSSL_PROVIDER_load(nullptr, "legacy");
}

void OpenSSLCrypto::threadsCleanup()
{
    if (legacyProvider)
    {
        OSSL_PROVIDER_unload(legacyProvider);
        legacyProvider = nullptr;
    }

    if (defaultProvider)
    {
        OSSL_PROVIDER_unload(defaultProvider);
        defaultProvider = nullptr;
    }
}
