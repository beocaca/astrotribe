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

      <!-- PDF Embed -->
      <div class="max-w-5xl mx-auto">
        <div
          class="bg-primary-900/30 backdrop-blur-sm rounded-lg overflow-hidden border border-primary-800/30 shadow-xl"
        >
          <!-- PDF Viewer -->
          <div class="aspect-[8.5/11] w-full">
            <iframe
              src="/documents/AstronEra_Endorsement_DarkSky_Dec_2025.pdf"
              class="w-full h-full"
              title="DarkSky International Endorsement Letter"
            />
          </div>

          <!-- Download Button -->
          <div class="p-6 bg-primary-900/50 flex justify-center">
            <a
              href="/documents/AstronEra-Endorsement-DSI-2025.pdf"
              download="AstronEra_DarkSky_Endorsement_2025.pdf"
              class="inline-flex items-center gap-2 px-6 py-3 bg-primary-600 hover:bg-primary-500 rounded-lg transition-colors"
            >
              <Icon
                name="mdi:download"
                size="20px"
              />
              <span>Download Official Letter (PDF)</span>
            </a>
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
