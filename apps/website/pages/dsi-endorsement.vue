<script setup lang="ts">
useHead({
  title: 'DarkSky International Endorsement - AstronEra',
  meta: [
    {
      name: 'description',
      content:
        "Official endorsement of AstronEra as DarkSky International's Maharashtra Partner for dark sky conservation and technical coordination.",
    },
  ],
})
</script>

<template>
  <div class="dark relative z-0 bg-gradient-to-b from-[#05070f] to-[#0e111c] text-white">
    <div class="wrapper relative z-10 py-16 md:py-24">
      <!-- Simple Header -->
      <div class="text-center mb-12">
        <h1 class="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-4">
          DarkSky International Endorsement
        </h1>
        <p class="text-lg md:text-xl text-primary-200 max-w-3xl mx-auto">
          Official recognition of AstronEra as DarkSky International's Maharashtra Partner for
          technical support, coordination, and government interface.
        </p>
      </div>

      <!-- PDF Actions -->
      <div class="max-w-5xl mx-auto">
        <div
          class="bg-primary-900/30 backdrop-blur-sm rounded-lg overflow-hidden border border-primary-800/30 shadow-xl"
        >
          <!-- Document Icon & Info -->
          <div class="p-12 text-center">
            <div
              class="inline-flex items-center justify-center w-24 h-24 mb-6 bg-primary-800/50 rounded-full"
            >
              <Icon
                name="mdi:file-document"
                size="48px"
                class="text-primary-400"
              />
            </div>
            <h3 class="text-2xl font-bold text-white mb-2">Official Endorsement Letter</h3>
            <p class="text-primary-200 mb-8">December 18, 2025 - DarkSky International</p>

            <!-- Action Buttons -->
            <div class="flex flex-col sm:flex-row gap-4 justify-center">
              <a
                href="/documents/AstronEra-Endorsement-DSI-2025.pdf"
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center justify-center gap-2 px-6 py-3 bg-primary-600 hover:bg-primary-500 rounded-lg transition-colors text-white font-medium"
              >
                <Icon
                  name="mdi:open-in-new"
                  size="20px"
                />
                <span>Open PDF in New Tab</span>
              </a>

              <a
                href="/documents/AstronEra-Endorsement-DSI-2025.pdf"
                download="AstronEra_DarkSky_Endorsement_2025.pdf"
                class="inline-flex items-center justify-center gap-2 px-6 py-3 bg-transparent border-2 border-primary-600 hover:bg-primary-900/50 rounded-lg transition-colors text-white font-medium"
              >
                <Icon
                  name="mdi:download"
                  size="20px"
                />
                <span>Download PDF</span>
              </a>
            </div>
          </div>
        </div>

        <!-- Quick Facts -->
        <div class="mt-8 grid grid-cols-1 md:grid-cols-3 gap-4 text-center">
          <div
            class="bg-primary-900/30 backdrop-blur-sm rounded-lg p-4 border border-primary-800/30"
          >
            <div class="text-primary-400 font-bold">Recognition Date</div>
            <div class="text-white text-lg">December 18, 2025</div>
          </div>
          <div
            class="bg-primary-900/30 backdrop-blur-sm rounded-lg p-4 border border-primary-800/30"
          >
            <div class="text-primary-400 font-bold">Scope</div>
            <div class="text-white text-lg">Maharashtra State Partner</div>
          </div>
        </div>

        <!-- Back to Dark Sky Page -->
        <div class="mt-12 text-center">
          <NuxtLink to="/darksky">
            <PrimeButton
              class="bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 border-0"
            >
              <Icon
                name="mdi:arrow-left"
                class="mr-2"
              />
              Learn About Our Dark Sky Work
            </PrimeButton>
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>
