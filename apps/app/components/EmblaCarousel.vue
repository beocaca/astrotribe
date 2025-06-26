<script setup lang="ts" generic="T">
import { ref, onMounted, watch } from 'vue'
import useEmblaCarousel from 'embla-carousel-vue'
import type { EmblaOptionsType } from 'embla-carousel'

const props = defineProps<{
  items: T[]
  type: string
  hasNavigation?: boolean
}>()

// Embla configuration for gentle scale carousel
const options: EmblaOptionsType = {
  loop: true,
  align: 'center',
  containScroll: 'trimSnaps',
  slidesToScroll: 1,
  duration: 15, // Gentle movement
}

const [emblaRef, emblaApi] = useEmblaCarousel(options)

const tweenFactor = ref(0.3) // Reduced for gentler effect
const tweenNodes = ref<HTMLElement[]>([])

const scrollPrev = () => {
  emblaApi.value?.scrollPrev()
}

const scrollNext = () => {
  emblaApi.value?.scrollNext()
}

const canScrollPrev = ref(false)
const canScrollNext = ref(false)

const setTweenNodes = () => {
  if (!emblaApi.value) return
  tweenNodes.value = emblaApi.value.slideNodes()
}

const setTweenFactor = () => {
  if (!emblaApi.value) return
  tweenFactor.value = 0.3 * emblaApi.value.scrollSnapList().length
}

const tweenScale = () => {
  if (!emblaApi.value || !tweenNodes.value.length) return

  const engine = emblaApi.value.internalEngine()
  const scrollProgress = emblaApi.value.scrollProgress()
  const slidesInView = emblaApi.value.slidesInView()
  const isScrollEvent = engine.dragHandler.pointerDown()

  emblaApi.value.scrollSnapList().forEach((scrollSnap, snapIndex) => {
    let diffToTarget = scrollSnap - scrollProgress
    const slidesInSnap = engine.slideRegistry[snapIndex]

    slidesInSnap?.forEach((slideIndex) => {
      if (isScrollEvent && !slidesInView.includes(slideIndex)) return

      if (engine.options.loop) {
        engine.slideLooper.loopPoints.forEach((loopItem) => {
          const target = loopItem.target()

          if (slideIndex === loopItem.index && target !== 0) {
            const sign = Math.sign(target)

            if (sign === -1) {
              diffToTarget = scrollSnap - (1 + scrollProgress)
            }
            if (sign === 1) {
              diffToTarget = scrollSnap + (1 - scrollProgress)
            }
          }
        })
      }

      const tweenValue = 1 - Math.abs(diffToTarget * tweenFactor.value)
      const scale = Math.max(0.75, tweenValue) // Background cards more visible (0.75 vs 0.7)
      const opacity = Math.max(0.6, tweenValue) // Background cards more visible
      const slideNode = tweenNodes.value[slideIndex]

      if (slideNode) {
        slideNode.style.transform = `scale(${scale})`
        slideNode.style.opacity = `${opacity}`
        // Add slight translation for depth effect
        const translateY = (1 - tweenValue) * 10
        slideNode.style.transform = `scale(${scale}) translateY(${translateY}px)`
      }
    })
  })
}

const updateButtons = () => {
  if (!emblaApi.value) return
  canScrollPrev.value = emblaApi.value.canScrollPrev()
  canScrollNext.value = emblaApi.value.canScrollNext()
}

onMounted(() => {
  if (emblaApi.value) {
    setTweenNodes()
    setTweenFactor()
    tweenScale()

    emblaApi.value
      .on('reInit', setTweenNodes)
      .on('reInit', setTweenFactor)
      .on('reInit', tweenScale)
      .on('scroll', tweenScale)
      .on('select', updateButtons)
      .on('reInit', updateButtons)

    updateButtons()
  }
})

watch(
  () => props.items,
  () => {
    if (emblaApi.value) {
      emblaApi.value.reInit()
    }
  },
)
</script>

<template>
  <div class="embla-scale">
    <!-- Navigation Arrows -->
    <div
      v-if="hasNavigation && items.length > 1"
      class="embla__controls"
    >
      <div class="embla__buttons">
        <button
          class="embla__button embla__button--prev"
          type="button"
          :disabled="!canScrollPrev"
          @click="scrollPrev"
        >
          <Icon
            name="mdi:chevron-left"
            size="24"
          />
        </button>
        <button
          class="embla__button embla__button--next"
          type="button"
          :disabled="!canScrollNext"
          @click="scrollNext"
        >
          <Icon
            name="mdi:chevron-right"
            size="24"
          />
        </button>
      </div>
    </div>

    <!-- Embla Viewport -->
    <div
      v-if="items.length > 0"
      ref="emblaRef"
      class="embla__viewport"
    >
      <div class="embla__container">
        <div
          v-for="(item, index) in items"
          :key="`${type}-${index}`"
          class="embla__slide"
        >
          <div class="embla__slide__inner">
            <slot :item="item" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.embla-scale {
  position: relative;
  max-width: 100%;
  margin: 0 auto;
  padding: 2rem 0; /* Y-axis padding to prevent hover cutoff */
}

.embla__viewport {
  overflow: hidden;
}

.embla__container {
  display: flex;
  touch-action: pan-y pinch-zoom;
  margin-left: -2rem; /* Adjusted for better background card visibility */
}

.embla__slide {
  transform: translate3d(0, 0, 0);
  flex: 0 0 60%; /* Smaller cards - show more background */
  min-width: 0;
  padding-left: 2rem;
  transition:
    opacity 0.4s ease,
    transform 0.4s ease;
}

.embla__slide__inner {
  height: 200px; /* Smaller card height */
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  z-index: 1;
}

.embla__controls {
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  z-index: 10;
  transform: translateY(-50%);
  pointer-events: none;
}

.embla__buttons {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 1rem; /* Reduced padding for smaller layout */
}

.embla__button {
  pointer-events: auto;
  width: 2.5rem; /* Smaller buttons */
  height: 2.5rem;
  border-radius: 50%;
  background-color: rgba(30, 41, 59, 0.95);
  border: none;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
}

.embla__button:hover:not(:disabled) {
  background-color: rgba(51, 65, 85, 0.95);
  transform: scale(1.05);
}

.embla__button:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.embla__button--prev {
  margin-left: -1rem;
}

.embla__button--next {
  margin-right: -1rem;
}

/* Mobile responsive */
@media (max-width: 1024px) {
  .embla__slide {
    flex: 0 0 80%; /* Larger on mobile */
  }
}

@media (max-width: 768px) {
  .embla__slide {
    flex: 0 0 85%;
  }

  .embla__buttons {
    padding: 0 0.5rem;
  }

  .embla__button {
    width: 2rem;
    height: 2rem;
  }

  .embla__button--prev {
    margin-left: -0.5rem;
  }

  .embla__button--next {
    margin-right: -0.5rem;
  }
}
</style>
